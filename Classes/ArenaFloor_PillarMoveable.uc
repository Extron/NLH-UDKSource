/*******************************************************************************
	ArenaFloor_PillarMoveable

	Creation date: 02/02/2014 16:02
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaFloor_PillarMoveable extends InterpActor;

var PointLightComponent Light;
var float StartHeight;
var float EndHeight;
var float Duration;
var float Counter;

simulated function Initialize()
{
	ClearTimer('Recycle');
	SetHidden(false);
	StaticMeshComponent.SetHidden(false);
	SetTickIsDisabled(false); 
	SetPhysics(PHYS_RigidBody);
	SetCollision(true, true, true);
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	SetPhysics(PHYS_RigidBody);
	CollisionComponent.SetRBPosition(Location);
	CollisionComponent.SetRBCollidesWithChannel(RBCC_Default, false);
}

simulated function Tick(float dt)
{
	super.Tick(dt);

	CollisionComponent.SetRBPosition(Location * vect(1, 1, 0) + (vect(0, 0, 1) * Lerp(StartHeight, EndHeight, Counter / Duration)));

	Counter += dt;
	
	if (Counter >= Duration)
	{
		ArenaFloor_Pillar(Owner).EndMove();
		ArenaFloor_Pillar(Owner).Light.SetEnabled(Light.bEnabled);
		Destroy();
	}
}

simulated event FellOutOfWorld(class<DamageType> dmgType)
{
	//Normally, when a physics actor falls out of the world, it is automatically destroyed.  Here, we override to 
	//prevent that, as we spawn the actor beneath the world.
	//Super.FellOutOfWorld(dmgType);
}


defaultproperties
{
	bCollideActors=true
	bBlockActors=true
	bCollideWorld=false
	bNoDelete=false
	
	Begin Object Class=StaticMeshComponent Name=MeshObject
		StaticMesh=StaticMesh'AO_ArenaFloor.Meshes.PillarSimple'
		BoundsScale=3
		LightEnvironment=None
		bUsePrecomputedShadows=true
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
	
	CollisionComponent=MeshObject
}