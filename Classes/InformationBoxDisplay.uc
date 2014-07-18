/*******************************************************************************
	InformationBoxDisplay

	Creation date: 29/06/2014 02:47
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class InformationBoxDisplay extends SkeletalMeshActor;

/**
 * The render target to use to display the kill display.
 */
var TextureRenderTarget2D RenderTarget;

/**
 * The material to use on the information box.
 */
var MaterialInstanceConstant Material;

/**
 * The Scaleform display to use to display kill info.
 */
var GFx_InformationBox InfoBoxGFx;

/**
 * The mesh that the info box is attached to.
 */
var PlayerFigure Figure;

/**
 * The location that the info box will be at when it is in the active state.
 */
var vector ActiveLocation;

/**
 * The starting position the info box was at when it was activated.
 */
var vector StartingLocation;

/**
 * The rotation that the info box will have when it is in the active state.
 */
var rotator ActiveRotation;

/**
 * The starting rotation that the info box was at when it was activated.
 */
var rotator StartingRotation;

/**
 * The details layout the box should be using.
 */
var string Layout;

/**
 * The scale that the info box will have when it is in the active state.
 */
var float ActiveScale;

/**
 * The starting scale that the info box was at when it was activated.
 */
var float StartingScale;

/**
 * The time it takes for the info box to travel from its starting position to its active position.
 */
var float ActiveTravelTime;

/**
 * The counter for the travel time.
 */
var float ActiveTravelCounter;

/**
 * The socket the info box is attached to.
 */
var name Socket;

/**
 * Indicates that the information box is currently activated.
 */
var bool Activated;

delegate PopulateData(GFxObject data, GFx_InformationBox sender);

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	InfoBoxGFx = new class'Arena.GFx_InformationBox';
	
	SkeletalMeshComponent.SetTraceBlocking(true, true);
	
	if (InfoBoxGFx != None)
	{
		RenderTarget = class'TextureRenderTarget2D'.static.Create(416, 544);
		
		Material = new class'MaterialInstanceConstant';
		Material.SetParent(SkeletalMeshComponent.GetMaterial(0));
		Material.SetTextureParameterValue('RenderTarget', RenderTarget);
		SkeletalMeshComponent.SetMaterial(0, Material);
		
		InfoBoxGFx.Parent = self;
		InfoBoxGFx.SetMovieInfo(SwfMovie'ArenaUI.InformationBox');
		InfoBoxGFx.RenderTexture = RenderTarget;
		InfoBoxGFx.SetTimingMode(TM_Real);
		InfoBoxGFx.Init();
		InfoBoxGFx.Start();
	}
}

simulated function Tick(float dt)
{
	local vector socketLoc;
	local rotator r;
	
	if (Activated)
	{
		if (ActiveTravelCounter < ActiveTravelTime)
			ActiveTravelCounter += dt;

			SetLocation(VLerp(StartingLocation, ActiveLocation, FClamp(ActiveTravelCounter / ActiveTravelTime, 0, 1)));
			SetRotation(RLerp(StartingRotation, ActiveRotation, FClamp(ActiveTravelCounter / ActiveTravelTime, 0, 1), true));
			SkeletalMeshComponent.SetScale(4 * Lerp(StartingScale, ActiveScale, FClamp(ActiveTravelCounter / ActiveTravelTime, 0, 1)));
	}
	else
	{
		Figure.Avatar.BodyParts[BPTHead].MeshComponent.GetSocketWorldLocationAndRotation(Socket, socketLoc);
		
		r = Figure.Rotation;
		
		if (r.Roll < 0)
			r.Pitch += 16384;
		else
			r.Pitch -= 16384;
			
		if (ActiveTravelCounter < ActiveTravelTime)
			ActiveTravelCounter += dt;

		SetLocation(VLerp(StartingLocation, socketLoc, FClamp(ActiveTravelCounter / ActiveTravelTime, 0, 1)));
		SetRotation(RLerp(StartingRotation, r, FClamp(ActiveTravelCounter / ActiveTravelTime, 0, 1), true));
		SkeletalMeshComponent.SetScale(4 * Lerp(StartingScale, Figure.DrawScale, FClamp(ActiveTravelCounter / ActiveTravelTime, 0, 1)));
	}
}

function Activate()
{
	if (InfoBoxGFx.DataObject != None)
	{
		if (PopulateData != None) PopulateData(InfoBoxGFx.DataObject, InfoBoxGFx);
		InfoBoxGFx.PopulateInformation(Layout, InfoBoxGFx.DataObject);
	}
	
	InfoBoxGFx.Activate();
		
	Activated = true;
	ActiveTravelCounter = 0;
	StartingLocation = Location;
	StartingRotation = Rotation;
	StartingScale = SkeletalMeshComponent.Scale * 0.25;
}

function Deactivate()
{
	//InfoBoxGFx.Deactivate();
	
	Activated = false;
	ActiveTravelCounter = 0;
	StartingLocation = Location;
	StartingRotation = Rotation;
	StartingScale = SkeletalMeshComponent.Scale * 0.25;
}

function GetCornerWorldLoc(out vector topLeft, out vector bottomRight)
{
	SkeletalMeshComponent.GetSocketWorldLocationAndRotation('TopLeftSocket', topLeft);
	SkeletalMeshComponent.GetSocketWorldLocationAndRotation('BottomRightSocket', bottomRight);
}

defaultproperties
{
	Begin Object Name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'ArenaObjects.Meshes.InfoBoxDisplay'
		PhysicsAsset=PhysicsAsset'ArenaObjects.Meshes.InfoBoxDisplay_Physics'
		DepthPriorityGroup=SDPG_Foreground
	End Object
	
	bNoDelete=false
	
	ActiveTravelTime=0.15
	ActiveTravelCounter=0.3
}