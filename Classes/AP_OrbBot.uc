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

simulated function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	
	`log("Bot took damage." @ DamageAmount @ DamageType @ Health);
}

function SetMovementPhysics()
{
	if (Physics != PHYS_Flying)
	{
		SetPhysics(PHYS_Flying);
	}
}

function SetDyingPhysics()
{
	if (Physics != PHYS_RigidBody)
		SetPhysics(PHYS_RigidBody);
}

function InitInventory()
{
	local Wp_OrbGun newWeapon;
	
	if (ArenaBot(Owner) != None)
	{
		newWeapon = spawn(class'Arena.Wp_OrbGun', Self, , Location, Rotation);
	}
	
	if (ArenaInventoryManager(InvManager) != None)
	{	
		if (newWeapon != None)
		{
			`log("Adding Orb's weapon.");
			InvManager.AddInventory(newWeapon);
			InvManager.NextWeapon();
		}
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
		SetLocation(Location + offset);
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
		Rotation=(Yaw=-16384)
	End Object
	
	Begin Object Name=NewStats
		Values[PSVHealthRegenDelay]=5
	End Object
	
	CollisionComponent=WPawnSkeletalMeshComponent
	
	bCanStrafe=true
	bCanFly=true
	
	AirSpeed=200
	
	ControllerClass=class'Arena.ArenaBot'
	
	Location=(Z=100)
}