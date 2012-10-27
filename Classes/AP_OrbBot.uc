/*******************************************************************************
	AP_OrbBot

	Creation date: 15/10/2012 09:56
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * A pawn that represests the Orb drone, a simplistic hovering robot.
 */
class AP_OrbBot extends ArenaPawn;

var float Counter;

function SetMovementPhysics()
{
	if (Physics != PHYS_Flying)
	{
		SetPhysics(PHYS_Flying);
	}
}


auto state Idle
{
	simulated function Tick(float dt)
	{
		local vector offset;
		
		global.Tick(dt);
		
		Counter += dt;

		offset.Z = Cos(Counter);
		//SetLocation(Location + offset);
	}
}

state MoveToTarget
{
}

defaultproperties
{
	Begin Object Name=WPawnSkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'AC_Orb.Meshes.OrbMesh'
		PhysicsAsset=PhysicsAsset'AC_Orb.Meshes.OrbMesh_Physics'
	End Object
	
	MovementSpeedModifier=0.15
	
	ControllerClass=class'Arena.ArenaBot'
	Location=(Z=100)
}