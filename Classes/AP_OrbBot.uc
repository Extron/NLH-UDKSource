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
 * A counter to keep track of time.
 */
var float Counter;

/**
 * The azimuthal direction that the orb should be orbiting.  Negative indicates counter-clockwise, positive is clockwise.
 */
var float OrbitAzimuthDirection;

/**
 * The zenithal direction that the orb should be orbiting.  Positive indicates downwards, negative indicates upwards.
 */
var float OrbitZenithDirection;

/**
 * The minimum zenith that the orb can have.
 */
var float ZenithMin;

/**
 * The maximum zenith that the orb can have.
 */
var float ZenithMax;

/**
 * The zenithal direction that the orb should be orbiting.  Positive indicates downwards, negative indicates upwards.
 */
var float OrbitRadialDirection;

/**
 * The minimum zenith that the orb can have.
 */
var float RadiusMin;

/**
 * The maximum zenith that the orb can have.
 */
var float RadiusMax;

/**
 * The total amount of time the orb should orbit before stopping.
 */
var float OrbitTimer;

/**
 * The maximum time the orb should orbit for.
 */
var float OrbitTimeMax;

/**
 * The minimum time a bot should orbit for.
 */
var float OrbitTimeMin;

/**
 * The azimuthal speed at which the bot will orbit.
 */
var float OrbitSpeedAzimuth;

/**
 * The zenithal speed at which the bot will orbit.
 */
var float OrbitSpeedZenith;

/**
 * The radial speed at which the bot will drift.
 */
var float OrbitSpeedRadial;

/**
 * The minimum speed that the orb will orbit.
 */
var float OrbitSpeedMin;

/**
 * The maximum speed that the bot will orbit.
 */
var float OrbitSpeedMax;

/**
 * To enhance unpredictibility, an orb will not always be allowed to orbit.  This value functions as a bias on the 
 * probability that the orb can orbit.  For example, if this value is 0.5, then the bot has a 50% chance to orbit,
 * and if it is 0.9, the bot has a 90% chance of orbitinig.
 */
var float OrbitBias;

/**
 * Indicates whether the orb is orbiting or not.
 */
var bool IsOrbiting;



simulated function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	
	`log("Bot Taking damage" @ self);
}

simulated function Recover()
{
	super.Recover();
	SetMovementPhysics();
}

function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	local bool ret;
	
	ret = super.Died(Killer, DamageType, HitLocation);
	
	`log("Pawn is dying.");
	Ragdoll();
	return ret;
}

function SetMovementPhysics()
{
	if (Physics != PHYS_Flying)
		SetPhysics(PHYS_Flying);
}

function SetDyingPhysics()
{
	if (Physics != PHYS_RigidBody)
		SetPhysics(PHYS_RigidBody);
}

simulated function RebootElectronics(ArenaPawn pawn)
{
	`log("Rebooting");
	
	if (ArenaBot(Owner) != None)
		ArenaBot(Owner).Stun(5);
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
	}
}

/**
 * This computes the radial bais of the bot's orbiting motion.  Radial distance of the bot is dependant on the 
 * bot's aggresiveness, so the more aggressive the bot is, the closer it should get, and the more cautios it is,
 * the further the bot should get.
 */
function float RadiusBias()
{
	local float bias;
	
	if (ArenaBot(Controller) != None)
	{
		if (ArenaBot(Controller).IsAggressive())
			bias -= 0.25;
		else if (ArenaBot(Controller).IsCautious())
			bias += 0.25;
		else if (ArenaBot(Controller).IsRetreating())
			bias += 0.5;
			
		return bias;
	}
	
	return 0;
}

simulated function bool CanShoot()
{
	return !IsOrbiting;
}

auto state Idle
{
	simulated function Tick(float dt)
	{
		local vector offset;
		
		global.Tick(dt);
		
		Counter += dt;

		offset.Z = 0.5 * Cos(Counter);
		SetLocation(Location + offset);
	}
}

state MoveToTarget
{
}

state Focusing
{
Begin:
	if (FRand() <= OrbitBias)
		GoToState('Orbiting');
	else
		GoToState('Sleeping');
}

state Orbiting extends Focusing
{
	simulated function Tick(float dt)
	{
		local vector r, v_az, v_zen, v_rad;
		local float zenith, radius;
		local float speed_az, speed_zen, speed_rad;
		
		global.Tick(dt);
	
		AddVelocity(-Velocity, vect(0, 0, 0), None);
	
		
		if (Counter >= OrbitTimer)
		{
			IsOrbiting = false;
			return;
		}
			
		Counter += dt;
		
		r = Normal(Controller.Focus.Location - Location);
		radius = VSize(Controller.Focus.Location - Location);
		
		v_az = (r cross vect(0, 0, 1)) * OrbitAzimuthDirection;
		
		zenith = ACos(Location.z / radius);
		
		if (zenith > ZenithMin && zenith < ZenithMax) 
			v_zen = (r cross Normal(v_az)) * OrbitZenithDirection;
		
		if (radius < RadiusMax && radius > RadiusMin)
			v_rad = Normal(r) * OrbitRadialDirection;
			
		speed_az = -((4 * OrbitSpeedAzimuth) / (OrbitTimer ** 2)) * (Counter - OrbitTimer * 0.5) ** 2 + OrbitSpeedAzimuth;
		speed_zen = -((4 * OrbitSpeedZenith) / (OrbitTimer ** 2)) * (Counter - OrbitTimer * 0.5) ** 2 + OrbitSpeedZenith;
		speed_rad = -((4 * OrbitSpeedRadial) / (OrbitTimer ** 2)) * (Counter - OrbitTimer * 0.5) ** 2 + OrbitSpeedRadial;
		
		AddVelocity(v_az * speed_az + v_zen * speed_zen * 0.5 + v_rad * speed_rad * 0.5, vect(0, 0, 0), None);
	}
	
Begin:
	OrbitAzimuthDirection = FRand() >= 0.5 ? (FRand() >= 0.5 ? 1 : -1) : 0;
	OrbitZenithDirection = FRand() >= 0.5 ? (FRand() >= 0.25 ? 1 : -1) : 0;
	OrbitRadialDirection = FRand() >= 0.5 - Abs(RadiusBias()) ? (FRand() >= 0.5 + RadiusBias() ? 1 : -1) : 0;
	OrbitTimer = Lerp(OrbitTimeMin, OrbitTimeMax, FRand());
	OrbitSpeedAzimuth = Lerp(OrbitSpeedMin, OrbitSpeedMax, FRand());
	OrbitSpeedZenith = Lerp(OrbitSpeedMin, OrbitSpeedMax, FRand());
	OrbitSpeedRadial = Lerp(OrbitSpeedMin, OrbitSpeedMax, FRand()) * (1 + Abs(RadiusBias()) * 4);
	IsOrbiting = true;
	Counter = 0;
}

state Sleeping
{
	simulated function Tick(float dt)
	{
		local vector offset;
		
		global.Tick(dt);
		
		Counter += dt;

		offset.Z = 0.5 * Cos(2.0 * Counter);
		//SetLocation(Location + offset);
	}
	
Begin:
	IsOrbiting = true;
	Sleep(Lerp(OrbitTimeMin, OrbitTimeMax, FRand()));
	IsOrbiting = false;
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

state Wandering
{
	simulated event Tick(float dt)
	{
		global.Tick(dt);
		
		MovementSpeedModifier *= 0.5;
	}
}

state Evading
{
	simulated function bool IsEvading()
	{
		return Counter < OrbitTimer;
	}
	
	simulated function Tick(float dt)
	{
		local vector r, v_az, v_zen, v_rad;
		local float zenith, radius;
		local float speed_az, speed_zen, speed_rad;
		
		global.Tick(dt);

		if (Counter < OrbitTimer)
		{		
			AddVelocity(-Velocity, vect(0, 0, 0), None);
		
			Counter += dt;
			
			//if (Counter >= OrbitTimer)
			//{
				//ZeroMovementVariables();
				//return;
			//}
			
			r = Normal(Controller.Focus.Location - Location);
			radius = VSize(Controller.Focus.Location - Location);
			
			v_az = (r cross vect(0, 0, 1)) * OrbitAzimuthDirection;
			
			if (radius == 0)
				`log("Radius is zero, leading to divide by zero");
				
			zenith = ACos(Location.z / radius);
			
			if (zenith > ZenithMin && zenith < ZenithMax) 
				v_zen = (r cross Normal(v_az)) * OrbitZenithDirection;
			
			if (radius < RadiusMax && radius > RadiusMin)
				v_rad = Normal(r) * OrbitRadialDirection;
				
			if (OrbitTimer == 0)
				return;
				
			speed_az = -((4 * OrbitSpeedAzimuth) / (OrbitTimer ** 2)) * (Counter - OrbitTimer * 0.5) ** 2 + OrbitSpeedAzimuth;
			speed_zen = -((4 * OrbitSpeedZenith) / (OrbitTimer ** 2)) * (Counter - OrbitTimer * 0.5) ** 2 + OrbitSpeedZenith;
			speed_rad = -((4 * OrbitSpeedRadial) / (OrbitTimer ** 2)) * (Counter - OrbitTimer * 0.5) ** 2 + OrbitSpeedRadial;
			
			AddVelocity(v_az * speed_az + v_zen * speed_zen * 0.5 + v_rad * speed_rad * 0.5, vect(0, 0, 0), None);
		}
	}
	
Begin:
	if (ArenaBot(Controller).EvadeDirection dot ((Location - ArenaBot(Controller).Focus.Location) cross vect(0, 0, 1)) >= 0)
		OrbitAzimuthDirection = -1;
	else
		OrbitAzimuthDirection = 1;

	if (ArenaBot(Controller).EvadeDirection dot vect(0, 0, 1) >= 0)
		OrbitZenithDirection = 1;
	else
		OrbitZenithDirection = -1;
		
	OrbitRadialDirection = 0;//FRand() >= 0.5 - Abs(RadiusBias()) ? (FRand() >= 0.5 + RadiusBias() ? 1 : -1) : 0;
	OrbitTimer = Lerp(OrbitTimeMin, OrbitTimeMax, FRand()) * 0.75;
	OrbitSpeedAzimuth = Lerp(OrbitSpeedMin, OrbitSpeedMax, FRand()) * 2.5;
	OrbitSpeedZenith = Lerp(OrbitSpeedMin, OrbitSpeedMax, FRand()) * 2.5;
	OrbitSpeedRadial = 0;//Lerp(OrbitSpeedMin, OrbitSpeedMax, FRand()) * (1 + Abs(RadiusBias()) * 4);
	Counter = 0;	
}

defaultproperties
{
	Begin Object Name=WPawnSkeletalMeshComponent
		SkeletalMesh=SkeletalMesh'AC_Orb.Meshes.OrbMesh'
		PhysicsAsset=PhysicsAsset'AC_Orb.Meshes.OrbMesh_Physics'
		Rotation=(Yaw=-16384)
		MinDistFactorForKinematicUpdate=0.0
	End Object
	
	Begin Object Name=NewStats
		Values[PSVHealthRegenDelay]=5
	End Object
	
	OrbitTimeMax=1.5
	OrbitTimeMin=0.25
	OrbitSpeedMin=100
	OrbitSpeedMax=500
	ZenithMin=0.7853981
	ZenithMax=2.3561944
	RadiusMin=200
	RadiusMax=1000
	OrbitBias=0.85
	
	HealthMax=400
	Health=400
	FHealth=400
	
	bCanStrafe=true
	bCanFly=true
	
	//AirSpeed=200
	//MovementSpeedModifier = 0.5;
	
	ControllerClass=class'Arena.ArenaBot'
	
	Location=(Z=100)
}