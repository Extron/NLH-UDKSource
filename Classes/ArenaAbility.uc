/*******************************************************************************
	Ability

	Creation date: 24/06/2012 18:08
	Copyright (c) 2012, Trystan (Edited by Zack Diller)
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaAbility extends UDKWeapon;

/** The firing animation of the ability. */
var array<name> FireAnims;

/** The target of the ability. */
var ArenaPawn Target;

/** The sound of the ability firing. */
var SoundCue FireSound;

/**
 * The template to use for instant hits for the ability.
 */
var ParticleSystem IHBeamTemplate;

/**
 * The instance of the IH Beam particle system.
 */
var ParticleSystemComponent IHBeam;

/**
 * The ability-specific offset of the source location of the ability.
 * This can be thought as the displacement from the player's firing hand.
 */
var vector SourceOffset;

/** The name of the ability. */
var string AbilityName;

/* The amount of energy using this ability requires.  For abilities that can be sustained, this is on a per-tick basis. */
var float EnergyCost;

/* The cool down time of the ability. */
var float CoolDown;

/** The amount of time that the ability has been held. */
var float HeldTime;

/**
 * The amount of time that the ability has been changed.
 */
var float ChargeTime;

/**
 * Indicates the maximum allowed charging time.
 */
var float MaxCharge;

/**
 * Indicates the minimum allowed charging time.
 */
var float MinCharge;

/** The last cached dt. */
var float DeltaTime;

/** Indicates that the ability is being sustained; held down like a machine gun. */
var bool IsHolding;

/**
 * Indicates that the ability is being charged.
 */
var bool IsCharging;

/* Indicates if the player can use the ability right now. */
var bool CanFire;

/* Indicates that the player can hold down the fire ability button to sustain the ability. */
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
	else if (IsCharging)
	{
		ChargeTime += dt;
		
		if (ChargeTime >= MaxCharge)
		{
			`log("Charging maxed");
			StopFire(0);
		}
	}
}

/**
 * StartFire is called when the designated firing button is pressed.
 */
simulated function StartFire(byte FireModeNum)
{
	if (IsPassive) return;

	if (CanCharge && !IsCharging && CanFire)
	{
		`log("Beginning charge");
		CanFire = false;
		IsCharging = true;
		//SetPendingFire(0);
	}
	
	if (CanFire && ArenaPawn(Instigator) != None && ArenaPawn(Instigator).Energy >= EnergyCost)
	{
		`log("Firing weapon.");
		PlayArmAnimation('PlayerArmsAbilityOffHand', 0.0);
		super.StartFire(FireModeNum);
	}
}

/**
 * StopFire is called when the designated fire button is released.
 */
simulated function StopFire(byte FireModeNum)
{
	`log("Stop fire");
	
	if (IsHolding)
	{
		IsHolding = false;
		HeldTime = 0;
	}
	else if (IsCharging && ChargeTime >= MinCharge)
	{
		//Zack, do not change this part.  This code is what makes changed abilities work.  The way it works is 
		//that StopFire is called when the fire button is released, and if we have been charging it, the flags above 
		//will be true.  So we must call StartFire to begin the firing pipeline.  StartFire will handle all firing
		//logic like spending energy, setting cooldown time, etc.  But if we call super.StopFire, that will abort the
		//StartFire, so we return without calling it.
		`log("Charging complete");
        CanFire = true;
        StartFire(0);
        IsCharging = false;
        ChargeTime = 0;
        return;
	}
	else if (IsCharging && !CanFire)
	{
		`log("Charging aborted");
		IsCharging = false;
		CanFire = true;
		ChargeTime = 0;
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
		SetTimer(ArenaPawn(Instigator).Stats.GetCooldownTime(CoolDown), false, 'ReactivateAbility');
	}
	else if (CanHold)
	{
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
			if (ArenaPawn(Instigator).CanSpendEnergy(EnergyCost * DeltaTime))
				ArenaPawn(Instigator).SpendEnergy(EnergyCost * DeltaTime);
			else
				ArenaPawn(Instigator).SpendEnergy(ArenaPawn(Instigator).Energy);
		}
		else
			ArenaPawn(Instigator).SpendEnergy(EnergyCost);
	}
}

// Function added by Zack Diller - for when ability failed to be casted, refreshed energy spent and
// refreshes some of the cooldown, as determined by the RefreshRatio variable (0.0 - 1.0). Note: meant
//  only for abilities that cannot be held down.
function RefundAmmo(float RefreshRatio)
{
	if (ArenaPawn(Instigator) != None)
	{
		ArenaPawn(Instigator).AddEnergy(EnergyCost);

		SetTimer(CoolDown * RefreshRatio, false, 'ReactivateAbility');
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
		return ArenaPawn(Instigator).CanSpendEnergy(EnergyCost);
	}
	else
	{
		return false;
	}
}

simulated function InstantFire()
{
	local vector			StartTrace, EndTrace;
	local Array<ImpactInfo>	ImpactList;
	local int				Idx;
	local ImpactInfo		RealImpact;

	// define range to use for CalcWeaponFire()
	StartTrace = Instigator.GetWeaponStartTraceLocation();
	EndTrace = (StartTrace + vector(GetAdjustedAim(StartTrace)) * GetTraceRange()); //<< Stats.GetInaccuracyShift();

	// Perform shot
	RealImpact = CalcWeaponFire(StartTrace, EndTrace, ImpactList);

	if (Role == ROLE_Authority)
	{
		SetFlashLocation(RealImpact.HitLocation);	
	}

	EmitIHBeam(RealImpact.HitLocation);
	
	//InstantHitDamage[0] = BaseDamage * Stats.GetDamageModifier();
	
	for (Idx = 0; Idx < ImpactList.Length; Idx++)
	{
		ProcessInstantHit(CurrentFireMode, ImpactList[Idx]);
	}
}

simulated function PlayArmAnimation(name sequence, float duration, optional bool loop, optional SkeletalMeshComponent skelMesh)
{
	local AP_Player player;
	local AnimNodePlayCustomAnim node;

	if( WorldInfo.NetMode == NM_DedicatedServer || Instigator == None || !Instigator.IsFirstPerson())
		return;
	
	player = AP_Player(Instigator);

	if (player != None)
	{
		node = GetArmAnimNode();
		
		`log("Node" @ node);
		
		if (player.Arms == None || node == None)
			return;

		node.PlayCustomAnim(sequence, 1.0);
		
		//if (duration > 0.0)
		//{
		//}
		//else
		//{
			//node = AnimNodeSequence(player.Arms.Animations);
			//node.SetAnim(sequence);
			//node.PlayAnim(loop, DefaultAnimSpeed);
		//}
	}
}

simulated function AnimNodePlayCustomAnim GetArmAnimNode()
{
	local SkeletalMeshComponent skelMesh;

	if (AP_Player(Instigator) != None)
		skelMesh = AP_Player(Instigator).Arms;

	if (skelMesh != None)
		return AnimNodePlayCustomAnim(AnimTree(skelMesh.Animations).Children[0].Anim);

	return None;
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

/**
 * Emits the particle system used fot the instant hit projectile beam.
 *
 * @param hitLocation - The location where the shot hit.
 */
simulated function EmitIHBeam(vector hitLocation)
{
	local vector l;
	local rotator r;
	
	if (WorldInfo.NetMode != NM_DedicatedServer && IHBeamTemplate != None)
	{
		if (ArenaPawn(Instigator) != None)
			ArenaPawn(Instigator).GetAbilitySourceOffset(l, r);// + SourceOffset) >> );r
		
		r = Instigator.Controller.Rotation;
		l = l + (SourceOffset >> r);
		
		`log("Emitting beam." @ hitLocation @ l);
		
		IHBeam = WorldInfo.MyEmitterPool.SpawnEmitter(IHBeamTemplate, l);
		IHBeam.SetAbsolute(false, false, false);
		IHBeam.SetVectorParameter('HitLocation', hitLocation);
		IHBeam.SetVectorParameter('SourceLocation', l);
		IHBeam.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		IHBeam.bUpdateComponentInTick = true;
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
	//if (CanCharge) ChargedHasFired = false;
}

simulated function float GetRemainingCoolDownTime()
{
	return GetRemainingTimeForTimer('ReactivateAbility');
}

/**
 * Allows the ability to react when the player's pawn physically hits another pawn.
 *
 * @param pawn - The pawn that was touched.
 */
simulated function ProcessHitPawn(ArenaPawn pawn)
{
}

/**
 * Used for AI when using ability, gets the ideal range that the ability can be used in.
 */
simulated function float GetIdealRange()
{
	return WeaponRange;
}

defaultproperties
{
	FiringStatesArray[0]=WeaponFiring
	Spread[0]=0.0
	FireInterval[0]=1.0
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
	
	CanFire=true
	//ChargedHasFired=false
}