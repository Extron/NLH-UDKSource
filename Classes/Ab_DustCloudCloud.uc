/******************************************************************************
	Ab_DustCloudCloud
	
	Creation date: 09/06/2013 20:29
	Copyright (c) 2013, Zack Diller
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
	
	TODO:
	
	Needs a static mesh.
	Needs to affect all enemies inside.
******************************************************************************/

class Ab_DustCloudCloud extends Actor;

/* The shield's particle instance. */
var ParticleSystemComponent Shield;

/** The mesh used to draw the component. */
var() editinline MeshComponent Mesh;

simulated function Tick(float dt)
{
	SetLocation(Instigator.Location);
	
	super.Tick(dt);
}

defaultproperties
{
	bCollideActors=true
	bBlockActors=true
	
	Begin Object Class=StaticMeshComponent Name=ShieldMesh
		StaticMesh=StaticMesh'ArenaAbilities.Meshes.BubbleShieldMesh'
		DepthPriorityGroup=SDPG_PostProcess
		bOnlyOwnerSee=false
		bCastDynamicShadow=false
		CastShadow=false
		Scale=30
	End Object
	Mesh=ShieldMesh
	
	ShieldTimer=15.0
	DamageReduction=0.85
}