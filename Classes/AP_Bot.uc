/*******************************************************************************
	AP_Bot

	Creation date: 02/03/2013 22:47
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * A base pawn that is used exclusively for AI controlled bots.
 */
class AP_Bot extends ArenaPawn
	abstract;
	
var ParticleSystem DeathExplosionTemplate;

var ParticleSystemComponent DeathExplosion;

var class<UDKExplosionLight> DELClass;

var UDKExplosionLight DeathExplosionLight;

var bool MeshInvisibleOnDeath;

function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	if (MeshInvisibleOnDeath)
		Mesh.SetHidden(true);
		
	EmitDeathExplosion();
	
	return super.Died(Killer, DamageType, HitLocation);
}

function EmitDeathExplosion()
{
	if (DeathExplosionTemplate != None)
	{
		DeathExplosion = new class'ParticleSystemComponent';
		DeathExplosion.bAutoActivate = false;
		
		DeathExplosion.SetTemplate(DeathExplosionTemplate);
		DeathExplosion.ActivateSystem();
		
		AttachComponent(DeathExplosion);
	}
	
	if (DeathExplosionLight != None)
	{
		DeathExplosionLight.ResetLight();
	}
	else if (DELClass != None)
	{
		DeathExplosionLight = new(Outer) DELClass;
		AttachComponent(DeathExplosionLight);
	}
}

/**
 * Allows the pawn to govern when to shoot.
 */
simulated function bool CanShoot()
{
	return true;
}

/**
 * Allows the pawn to govern when it can use an ability.
 */
simulated function bool CanUseAbility()
{
	return true;
}

/**
 * Determines if the bot should use an ability at this point.
 */
simulated function bool HasAbility(ArenaPawn target)
{
	return false;
}

/**
 * Indicates that the pawn is currently evading.
 */
simulated function bool IsEvading()
{
	return false;
}

simulated function EnterWeatherVolume(WeatherManager weather)
{
	//TODO: Code some interesting stuff here.
}

simulated function ExitWeatherVolume()
{
	//TODO: Code some interesting stuff here.
}

/**
 * This is called when a bullet from a weapon passes near the bot.
 */
simulated function ShotAt(ArenaWeapon weap, Actor attacker, vector traceLoc, vector direction)
{
	if (ArenaBot(Owner) != None)
		ArenaBot(Owner).ShotAt(weap, attacker, traceLoc, direction);
}

auto state Idle
{
}

state MoveToTarget
{
}

state Focusing
{
}

state Stunned
{
}

state Recovering
{
}

state Wandering
{
}

state Evading
{
	simulated function bool IsEvading()
	{
		return true;
	}
}
