/******************************************************************************
	Ab_RockWall
	
	Creation date: 13/02/2013 14:08
	Copyright (c) 2013, Strange Box Software
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
******************************************************************************/

class Ab_RockWall extends ArenaAbility;

/* The wall that the ability generates. */
var Ab_RockWallBoulder Wall;

/**
 * The class to use for the boulder.  This can be overridden in subclasses to change what kind of wall is generated.
 */
var class<Ab_RockWallBoulder> WallClass;

/**
 * The particle system to play when the rock wall is rising.
 */
var ParticleSystem WallRiseTemplate;

/**
 * The particle system template to use to show the wall traveling.
 */
var ParticleSystem WallTravelTemplate;

/**
 * The particle system that shows the wall traveling.
 */
var EmitterSpawnable WallTravelParticles;

/** 
 * The sound to play while the wall is traveling.
 */
var AudioComponent WallTravelSound;

/**
 * The range of the ability.  This is mainly used to determine how high the player can be above the
 * ground and still summon the wall.
 */
var float Range;

/**
 * The height of the rock wall to use when checking bounds.
 */
var float Height;

/* The float that determines how far in the ground the pedestal starts */
var float StartDepth;

/* The float that determines how far away from the player the boulder spawns if
	called instantly.*/
var float MinWallDistance;

/* How much further away the wall will spawn per DeltaTime of charging up */
var float ChargeDistance;


simulated function StartFire(byte FireModeNum)
{
	local vector loc;
	
	loc = vect(1, 0, 0) << Instigator.Rotation;
	
	//This checks that we hit the floor, and that we don't hit the ceiling, before trying to cast the ability.
	if (!FastTrace(Instigator.Location + vect(0, 0, -1) * Range + loc, Instigator.Location + loc) &&
		FastTrace(Instigator.Location + vect(0, 0, 1) * Height + loc, Instigator.Location + loc))
	{		
		if (CanCharge && !IsCharging && CanFire)
		{
			if (WallTravelParticles == None)
			{
				WallTravelParticles = Spawn(class'EmitterSpawnable', self, , Instigator.Location);
				WallTravelParticles.SetTemplate(WallTravelTemplate);
				WallTravelParticles.AttachComponent(WallTravelSound);
				
				WallTravelSound.Stop();
				WallTravelSound.FadeIn(0.1, 1.0);
			}
			else
			{
				WallTravelParticles.SetLocation(Instigator.Location + vect(0, 0, -1) * Range + loc);
				WallTravelParticles.ParticleSystemComponent.SetActive(true);
				
				WallTravelSound.Stop();
				WallTravelSound.FadeIn(0.1, 1.0);
			}
		}
		
 		super.StartFire(FireModeNum);
	}
}

simulated function StopFire(byte FireModeNum)
{
	super.StopFire(FireModeNum);
	
	if (WallTravelParticles != None)
	{
		WallTravelParticles.ParticleSystemComponent.SetActive(false);
		WallTravelSound.FadeOut(0.1, 0.0);
	}
}

simulated function Tick(float dt)
{
	local vector loc, traceLoc, traceNorm;
	local float distance;
	
	super.Tick(dt);

	if (IsCharging && !PlayingChargeFireAnim && WallTravelParticles != None)
	{
		distance = ChargeTime * ChargeDistance + MinWallDistance;

		loc = vect(1, 0, 0) << Instigator.Rotation;
	
		loc.x *= distance;
		loc.y *= -distance;
		
		if (Trace(traceLoc, traceNorm, Instigator.Location + vect(0, 0, -1) * Range + loc, Instigator.Location + loc) != None)
			WallTravelParticles.SetLocation(traceLoc);
	}
}

simulated function CustomFire()
{
	local ParticleSystemComponent wallRise;
	local vector traceLoc, traceNorm, loc;
	local float distance;
	
	distance = ChargeTime * ChargeDistance + MinWallDistance;

	loc = vect(1, 0, 0) << Instigator.Rotation;
	
	loc.x *= distance;
	loc.y *= -distance;

	if (Trace(traceLoc, traceNorm, Instigator.Location + vect(0, 0, -1) * Range + loc, Instigator.Location + loc) != None)
	{
		Wall = Spawn(WallClass, None, , traceLoc + (vect(0, 0, -1) * StartDepth), Instigator.Rotation);		
		Wall.StartLocation = traceLoc + (vect(0, 0, -1) * StartDepth);
		Wall.EndLocation = traceLoc;
		Wall.Ability = self;
		
		wallRise = WorldInfo.MyEmitterPool.SpawnEmitter(WallRiseTemplate, traceLoc);
		wallRise.SetAbsolute(false, false, false);
		wallRise.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		wallRise.bUpdateComponentInTick = true;
		
		if (WallTravelParticles != None)
		{
			WallTravelParticles.ParticleSystemComponent.SetActive(false);
			WallTravelSound.FadeOut(0.1, 0.0);
		}
	}
}

defaultproperties
{
	WeaponFireTypes(0)=EWFT_Custom
	
	CoolDown=10
	EnergyCost=78
	AbilityName="Rock Wall"
	
	WallClass=class'Arena.Ab_RockWallBoulder'
	
	CanHold = false
	IsPassive = false
	CanCharge = true

	WallRiseTemplate=ParticleSystem'Solus.Particles.RockWallRisePS'
	WallTravelTemplate=ParticleSystem'Solus.Particles.RockWallTravelPS'
	FireSound=SoundCue'Solus.Audio.RockWallRiseSC'
	
	Begin Object Class=AudioComponent Name=Sound
		SoundCue=SoundCue'Solus.Audio.RockWallTravelSC'
	End Object
	WallTravelSound=Sound
	
	ChargeStartAnim=RockWallStart
	ChargingAnim=RockWallCharge
	ChargeEndAnim=RockWallEnd
	
	StartDepth=150
	Range=120
	Height=200
	MinWallDistance = 120
	ChargeDistance = 191.2

	MinCharge=0.0
	MaxCharge=3.0
}
