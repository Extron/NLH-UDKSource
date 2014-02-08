/*******************************************************************************
	AP_OrbBot

	Creation date: 15/10/2012 09:56
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * A pawn that represests the Orb drone, a simplistic hovering robot.
 */
class AP_OrbBot extends AP_Bot;

/**
 * The template scanning beam particle to use when the orb scans.
 */
var ParticleSystem ScannerBeamTemplate;

/**
 * The scanning beam particle to use when the orb scans.
 */
var ParticleSystemComponent ScannerBeam;

/**
 * A counter to keep track of time.
 */
var float Counter;



simulated function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	
	//`log("Bot Taking damage" @ self);
}

simulated function Recover()
{
	super.Recover();
	SetMovementPhysics();
}

function SetMovementPhysics()
{
	if (Physics != PHYS_Flying)
		SetPhysics(PHYS_Flying);
}

function SetDyingPhysics()
{
	//if (Physics != PHYS_RigidBody)
		//SetPhysics(PHYS_RigidBody);
		
	if (Physics != PHYS_None)
		SetPhysics(PHYS_None);
}

simulated function RebootElectronics(ArenaPawn pawn)
{
	if (ArenaBot(Owner) != None)
		ArenaBot(Owner).Stun(5);
}

/**
 * Orbs are always considered conductive.
 */
simulated function bool IsConductive()
{
	return true;
}

simulated function bool HasAbility(ArenaPawn target)
{
	if (ActiveAbility != None && target != None)
	{
		if (VSize(Location - target.Location) < ActiveAbility.GetIdealRange())
			return true;
	}
	
	return false;
}

function InitInventory()
{
	local Wp_OrbGun newWeapon;

	super.InitInventory();
	
	if (ArenaBot(Owner) != None)
	{
		newWeapon = spawn(class'Arena.Wp_OrbGun', Self, , Location, Rotation);
	}
	
	if (ArenaInventoryManager(InvManager) != None)
	{	
		if (newWeapon != None)
		{
			InvManager.AddInventory(newWeapon);
			InvManager.NextWeapon();
		}
		
		CreateInventory(class'Arena.Ab_ShockShort', true);

		ArenaInventoryManager(InvManager).NextAbility();
	}
}

function GetAbilitySourceOffset(out vector l, out rotator r)
{	
	if (Mesh.GetSocketByName('ArmSocket') != None)
	{
		Mesh.GetSocketWorldLocationAndRotation('ArmSocket', l, r, 0);
	}
}

auto state Idle
{
	simulated function Tick(float dt)
	{
		/*local vector offset;
		
		global.Tick(dt);
		
		Counter += dt;

		offset.Z = 0.5 * Cos(Counter);
		SetLocation(Location + offset);*/
	}
}

state Scanning
{

}

state Stunned
{
Begin:
	RagDoll();
}

state Recovering
{
Begin:
	Recover();
}

defaultproperties
{
	Begin Object Name=WPawnSkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'AC_Orb.Meshes.OrbBot'
		PhysicsAsset=PhysicsAsset'AC_Orb.Meshes.OrbBot_Physics'
		Rotation=(Yaw=16384)
		MinDistFactorForKinematicUpdate=0.0
	End Object
	
	Begin Object Name=NewStats
		Values[PSVHealthRegenDelay]=5
	End Object
	
	DeathExplosionTemplate=ParticleSystem'AC_Orb.Particles.DeathExplosionPS'
	DamageTemplate=ParticleSystem'AC_Orb.Particles.DamagePS'
	BloodSplatterTemplate=ParticleSystem'AC_Orb.Particles.BloodSplatterPS'
	DELClass=class'Arena.L_OrbDeathExplosion'
	
	HealthMax=400
	Health=400
	FHealth=400
	
	bCanStrafe=true
	bCanFly=true
	MeshInvisibleOnDeath=true
	
	//AirSpeed=200
	//MovementSpeedModifier = 0.5;
	
	ControllerClass=class'Arena.ArenaBot'
	
	Location=(Z=100)
	
	HasFootsteps=false
}