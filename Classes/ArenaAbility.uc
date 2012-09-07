/*******************************************************************************
	Ability

	Creation date: 24/06/2012 18:08
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaAbility extends UDKWeapon;

/** The firing animation of the ability. */
var array<name> FireAnims;

/** The sound of the ability firing. */
var SoundCue FireSound;

/** The name of the ability. */
var string AbilityName;

/* The amount of energy using this ability requires.  For abilities that can be sustained, this is on a per-tick basis. */
var float EnergyCost;

/* The cool down time of the ability. */
var float CoolDown;

/** The amount of time that the ability has been held. */
var float HeldTime;

/** The last cached dt. */
var float DeltaTime;

/** Indicates that the ability is being sustained. */
var bool IsHolding;

/* Indicates if the player can use the ability right now. */
var bool CanFire;

/* Indicates that the player can hold down the fire ability button to use the ability. */
var bool CanHold;

/* Indicates that the player can charge the ability. */
var bool CanCharge;

/* Indicates that the ability is passive, and non-equippable. */
var bool IsPassive;

simulated function Tick(float dt)
{
	if (IsHolding)
	{
		HeldTime += dt;
		DeltaTime = dt;
	}
}

simulated function StartFire(byte FireModeNum)
{
	if (CanFire && !IsPassive && ArenaPawn(Instigator) != None && ArenaPawn(Instigator).Energy >= EnergyCost)
	{
		super.StartFire(FireModeNum);
	}
}

simulated function StopFire(byte FireModeNum)
{
	if (IsHolding)
	{
		IsHolding = false;
		HeldTime = 0;
	}
		
	super.StopFire(FireModeNum);
}

simulated function FireAmmunition()
{
	super.FireAmmunition();
	
	if (CoolDown > 0 && !CanHold)
	{
		`log("Firing ability");
		AbilityPlaySound(FireSound);
		CanFire = false;
		ClearPendingFire(0);
		SetTimer(CoolDown, false, 'ReactivateAbility');
	}
	else if (CanHold)
	{
		`log("Firing ability");
		if (IsHolding && ArenaPawn(Instigator) != None && ArenaPawn(Instigator).Energy <= 0)
		{
			ClearPendingFire(0);
			CanFire = false;
			SetTimer(CoolDown > 0 ? CoolDown : 0.1, false, 'ReactivateAbility');
		}
		else if (!IsHolding)
		{
			IsHolding = true;
		}
	}
}

function ConsumeAmmo(byte FireModeNum)
{
	if (ArenaPawn(Instigator) != None)
	{
		if (IsHolding)
		{
			if (ArenaPawn(Instigator).Energy >= EnergyCost * DeltaTime)
				ArenaPawn(Instigator).SpendEnergy(EnergyCost * DeltaTime);
			else
				ArenaPawn(Instigator).SpendEnergy(ArenaPawn(Instigator).Energy);
		}
		else
			ArenaPawn(Instigator).SpendEnergy(EnergyCost);
	}
}

/*
 * This function checks to see if the weapon has any ammo available for a given fire mode.
 *
 * @param	FireModeNum The Fire Mode to Test For
 * @param	Amount [Optional] Check to see if this amount is available.
 * @return	true if ammo is available for Firemode FireModeNum.
 */
simulated function bool HasAmmo( byte FireModeNum, optional int Amount )
{
	if (ArenaPawn(Instigator) != None)
	{
		return ArenaPawn(Instigator).Energy >= EnergyCost;
	}
	else
	{
		return false;
	}
}

/**
 * This function handles playing sounds for weapons.  How it plays the sound depends on the following:
 *
 * If we are a listen server, then this sound is played and replicated as normal
 * If we are a remote client, but locally controlled (ie: we are on the client) we play the sound and don't replicate it
 * If we are a dedicated server, play the sound and replicate it to everyone BUT the owner (he will play it locally).
 *
 * @param	SoundCue	- The Source Cue to play
 */
simulated function AbilityPlaySound(SoundCue Sound)
{
	// if we are a listen server, just play the sound.  It will play locally
	// and be replicated to all other clients.
	if (Sound != None && Instigator != None)
	{
		Instigator.PlaySound(Sound, false, true);
	}
}

simulated function bool ShouldRefire()
{
	if (CanHold)
		return IsHolding && CanFire;
	else
		return CanFire;
}

simulated function ReactivateAbility()
{
	CanFire = true;
}

simulated function float GetRemainingCoolDownTime()
{
	return GetRemainingTimeForTimer('ReactivateAbility');
}

defaultproperties
{
	FiringStatesArray[0]=WeaponFiring
	Spread[0]=0.0
	FireInterval[0]=1.0
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
	
	CanFire=true
}