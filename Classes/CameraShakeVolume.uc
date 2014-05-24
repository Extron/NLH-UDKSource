/*******************************************************************************
	CameraShakeVolume

	Creation date: 05/04/2014 19:55
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * This is a spawnable volume that causes camera shaking for pawns that are inside it.  Has customaizable features such as shake amplitude attenuation.
 * The dimensions and shape of thi volume can be specified through its CollisionComponent, which is by default a cylinder.
 */
class CameraShakeVolume extends Actor;

/**
 * A list of pawns that are inside this volume.
 */
var array<Pawn> EncompassingPawns;

/**
 * The camera shake objects for each pawn in the volume.
 */
var array<CameraShake> PawnCameraShakes;

/**
 * The camera shake class to play for pawns inside this volume.
 */
var class<CameraShake> CameraShakeClass;

/**
 * The maximum strength of the camera shake at the center of the volume.
 */
var float MaxStrength;

/**
 * The lifetime of the volume.  If set to 0, then the volume persists indefinitely.
 */
var float Lifetime;

/**
 * Defines the linear drop off rate of the strength of the camera shake strength.
 */
var float LinearAttenuation;


simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	if (Lifetime > 0.0)
		SetTimer(Lifetime, false, 'LifetimeExpired');
}

simulated function Tick(float dt)
{
	local Camera playerCamera;
	local float distance;
	local float strength;
	local int shakeIndex;
	local int i;
	
	for (i = 0; i < EncompassingPawns.Length; i++)
	{
		distance = VSize(Location - EncompassingPawns[i].Location);
		strength = FClamp(MaxStrength - LinearAttenuation * distance, 0, MaxStrength);
		
		playerCamera = PlayerController(EncompassingPawns[i].Controller).PlayerCamera;
		shakeIndex = playerCamera.CameraShakeCamMod.ActiveShakes.Find('SourceShakeName', PawnCameraShakes[i].Name);
		
		if (shakeIndex > -1)
			playerCamera.CameraShakeCamMod.ActiveShakes[i].Scale = strength;
	}
}

simulated event Touch(Actor other, PrimitiveComponent otherComp, vector hitLocation, vector hitNormal)
{
	if (Pawn(other) != None)
		PawnEnteredVolume(Pawn(other));
}

simulated event UnTouch(Actor other)
{
	if (Pawn(other) != None)
		PawnLeavingVolume(Pawn(other));
}

event PawnEnteredVolume(Pawn enteringPawn)
{
	local CameraShake shake;
	
	if (PlayerController(enteringPawn.Controller) == None)
		return;

	
	EncompassingPawns.AddItem(enteringPawn);
	
	shake = new CameraShakeClass;
	
	if (Lifetime > 0.0)
		shake.OscillationDuration = Lifetime;
	else
		shake.OscillationDuration = 10000000000000000000000;
		
	PawnCameraShakes.AddItem(shake);
	PlayerController(enteringPawn.Controller).ClientPlayCameraShake(shake);
}

event PawnLeavingVolume(Pawn leavingPawn)
{
	local CameraShake shake;
	local int pawnIndex;
	
	if (PlayerController(leavingPawn.Controller) == None)
		return;

	pawnIndex = EncompassingPawns.Find(leavingPawn);
	
	if (pawnIndex > -1)
		shake = PawnCameraShakes[pawnIndex];
	
	PlayerController(leavingPawn.Controller).ClientStopCameraShake(shake);
	PawnCameraShakes.RemoveItem(shake);	
	
	EncompassingPawns.RemoveItem(leavingPawn);
}

function LifetimeExpired()
{
	Destroy();
}

defaultproperties
{
	Begin Object Class=CylinderComponent Name=CollisionCylinder
		CollisionRadius=512
		CollisionHeight=128
		CollideActors=true        
        BlockActors=false
	End Object
	CollisionComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

	MaxStrength=1
	bCollideActors=true
	bBlockActors=false
}