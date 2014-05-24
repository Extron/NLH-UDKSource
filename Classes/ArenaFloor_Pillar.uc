/*******************************************************************************
	ArenaFloor_Pillar

	Creation date: 09/01/2014 22:43
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaFloor_Pillar extends EnvironmentObject;

/**
 * The light component for the pillar.
 */
var PointLightComponent Light;

/**
 * The material used to draw the pillar.
 */
var MaterialInstanceConstant Material;

/**
 * The new height to set the pillar to when its done moving.
 */
var float NewHeight;

/**
 * The color of the lights on the pillar.
 */
var(Properties) color PillarColor;

/**
 * Indicates that the pillar's light is on.
 */
var(Properties) bool LightOn;

/**
 * Indicates that this pillar can spawn players.
 */
var(Properties) bool SpawnPlayers;

/**
 * Indicates that this pillar can spawn weapons.
 */
var(Properties) bool SpawnWeapons;

/**
 * Indicates that the pillar will randomly move up and down during a game.
 */
var(Properties) bool RandomMotion;

/**
 * How fast the pillar should change heights when moving.
 */
var(Properties) float MotionDuration<bShowOnlyWhenTrue=RandomMotion>;

/**
 * The minimum amount of time to wait before the pillar starts moving randomly.
 */
var(Properties) float MinRandomDuration<bShowOnlyWhenTrue=RandomMotion>;

/**
 * The maximum amount of time to wait before the pillar starts moving randomly.
 */
var(Properties) float MaxRandomDuration<bShowOnlyWhenTrue=RandomMotion>;

/**
 * The minimum height that the pillar can attain when moving randomly.
 */
var(Properties) float MinAllowedHeight<bShowOnlyWhenTrue=RandomMotion>;

/**
 * The maximum amount of time to wait before the pillar starts moving randomly.
 */
var(Properties) float MaxAllowedHeight<bShowOnlyWhenTrue=RandomMotion>;


function InitializeMaterial()
{
	Material = new class'MaterialInstanceConstant';
	Material.SetParent(StaticMeshComponent.GetMaterial(0));
	StaticMeshComponent.SetMaterial(0, Material);
}

function InitializeRandomMotion()
{
	SetTimer(Lerp(MinRandomDuration, MaxRandomDuration, FRand()), false, 'StartMove');
}

function StartMove()
{
	local ArenaFloor_PillarMoveable pillar;
	
	NewHeight = Lerp(MinAllowedHeight, MaxAllowedHeight, FRand());
	
	SetHidden(true);
	StaticMeshComponent.SetHidden(true);

	pillar = Spawn(class'Arena.ArenaFloor_PillarMoveable', self, , Location, Rotation, , true);
	pillar.StartHeight = Location.z;
	pillar.EndHeight = NewHeight;
	pillar.Duration = MotionDuration;
	
	pillar.StaticMeshComponent.SetMaterial(0, Material);
	pillar.Light.SetEnabled(Light.bEnabled);
	pillar.Light.SetLightProperties(, Light.LightColor);
	pillar.Light.UpdateColorAndBrightness();
	
	Light.SetEnabled(false);
}

function EndMove()
{
	SetHidden(false);
	StaticMeshComponent.SetHidden(false);
	SetLocation(Location * vect(1, 1, 0) + NewHeight * vect(0, 0, 1));
	InitializeRandomMotion();
}

function UpdateLighting()
{
	local LinearColor lColor;
	
	if (Material == None)
		InitializeMaterial();
		
	lColor.R = PillarColor.R / 255.0;
	lColor.G = PillarColor.G / 255.0;
	lColor.B = PillarColor.B / 255.0;
	lColor.A = PillarColor.A / 255.0;
	
	Light.SetEnabled(LightOn);
	Light.SetLightProperties(, PillarColor);
	Light.UpdateColorAndBrightness();
	Material.SetVectorParameterValue('EmissionTint', lColor);
}

defaultproperties
{
	bCollideActors=true
	bBlockActors=true
	bCollideWorld=false
	bMovable=true
	bNoDelete=false
	PillarColor=(R=255,G=5,B=5)
	
	Begin Object Class=StaticMeshComponent Name=MeshObject
		StaticMesh=StaticMesh'AO_ArenaFloor.Meshes.PillarSimple'
		BoundsScale=3
		RBCollideWithChannels=(Default=false)
		bUsePrecomputedShadows=true
		bCastDynamicShadow=false
	End Object
	StaticMeshComponent=MeshObject
	Components.Add(MeshObject)
	
	Begin Object Class=PointLightComponent Name=LightObject
		Translation=(Z=64)
		Brightness=7
		Radius=512
		LightColor=(R=255,G=0,B=0,A=255)
		CastShadows=false
		CastStaticShadows=false
		CastDynamicShadows=false
		bEnabled=false
	End Object
	Light=LightObject
	Components.Add(LightObject)
	
	bStatic=false
	CollisionComponent=MeshObject
}