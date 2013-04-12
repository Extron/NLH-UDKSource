/*******************************************************************************
	TestTarget

	Creation date: 01/07/2012 10:52
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class TestTarget extends ArenaPawn placeable;

var Ab_BubbleShield Shield;

simulated event TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	`log("I have taken damage.  Health" @ Health @ "Damage" @ DamageAmount @ "Damage Type" @ DamageType);
}

simulated function PostBeginPlay()
{
	`log("spawning shield");
	Shield = spawn(class'Ab_BubbleShield', self);
}

defaultproperties
{
	bBlockActors=True
	bCollideActors=True

	/*Begin Object Class=StaticMeshComponent Name=PickupMesh
		StaticMesh=StaticMesh'EngineMeshes.Cube'
		LightEnvironment=MyLightEnvironment
		Scale3D=(X=0.25,Y=0.25,Z=0.5)
	End Object*/
	//Components.Add(PickupMesh)
	
	RemoteRole=ROLE_SimulatedProxy 
	bAlwaysRelevant=true
}
