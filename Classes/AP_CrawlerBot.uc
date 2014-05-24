/*******************************************************************************
	AP_CrawlerBot

	Creation date: 21/04/2014 10:55
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class AP_CrawlerBot extends AP_Bot;

/**
 * A counter to keep track of time.
 */
var float Counter;


simulated function Recover()
{
	super.Recover();
	SetMovementPhysics();
}

function SetMovementPhysics()
{
	if (Physics != PHYS_Walking)
		SetPhysics(PHYS_Walking);
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
		SkeletalMesh=SkeletalMesh'AC_Crawler.Meshes.CrawlerMesh'
		PhysicsAsset=PhysicsAsset'AC_Crawler.Meshes.CrawlerMesh_Physics'
		AnimSets[0]=AnimSet'AC_Crawler.Animations.CrawlerAnimations'
		AnimTreeTemplate=AnimTree'AC_Crawler.Animations.CrawlerAnimationTree'
		Rotation=(Yaw=16384)
		MinDistFactorForKinematicUpdate=0.0
	End Object
	
	Begin Object Name=CollisionCylinder
		HiddenGame=false
		CollisionRadius=50
		CollisionHeight=30
	End Object

	
	Begin Object Name=NewStats
		Values[PSVHealthRegenDelay]=5
	End Object
	
	//DeathExplosionTemplate=ParticleSystem'AC_Orb.Particles.DeathExplosionPS'
	DamageTemplate=ParticleSystem'AC_Orb.Particles.DamagePS'
	BloodSplatterTemplate=ParticleSystem'AC_Orb.Particles.BloodSplatterPS'
	//DELClass=class'Arena.L_OrbDeathExplosion'
	
	HealthMax=300
	Health=300
	FHealth=300
	
	//bCanStrafe=true
	//bCanFly=true
	//MeshInvisibleOnDeath=true
	
	//AirSpeed=200
	//MovementSpeedModifier = 0.5;
	
	ControllerClass=class'Arena.Bot_Crawler'
	HasFootsteps=true
}