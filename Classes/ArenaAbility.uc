/*******************************************************************************
	Ability

	Creation date: 24/06/2012 18:08
	Copyright (c) 2012, Trystan (Edited by Zack Diller)
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaAbility extends UDKWeapon;

/**
 * The animation to play before the ability is fired.
 */
var name FireStartAnim;

/**
 * The animation to play before the ability is fired.
 */
var name FireEndAnim;

/**
 * The animation to play when starting to charge an ability.
 */
var name ChargeStartAnim;

/**
 * The anim te play while the ability is charging.
 */
var name ChargingAnim;

/**
 * The anim to play when firing a charged ability.
 */
var name ChargeFireAnim;

/**
 * The animation to play after a charged ability is fired.
 */
var name ChargeEndAnim;

/**
 * The animation to play if a charged ability is aborted.
 */
var name ChargeAbortAnim;

/**
 * The anim to play when starting a held ability.
 */
var name HoldStartAnim;

/**
 * The animation to play for a held ability.
 */
var name HoldingAnim;

/**
 * The animation to play if a held ability is ended.
 */
var name HoldEndAnim;

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
 * The template to use for particles when charging an ability.
 */
var ParticleSystem ChargeParticlesTemplate;

/**
 * The instance of the charging particle system.
 */
var ParticleSystemComponent ChargeParticles;

/**
 * The template to use for particles for when the ability hits something.
 */
var ParticleSystem SparkParticlesTemplate;

/**
 * The instance of the spark particle system.
 */
var ParticleSystemComponent SparkParticles;

/**
 * The light class to use for the spark light.
 */
var class<UDKExplosionLight> SLClass;

/**
 * The light to spawn when firing the ability.
 */
var UDKExplosionLight SparkLight;

/**
 * The light class to use for the discharge light.
 */
var class<UDKExplosionLight> DLClass;

/**
 * The light to spawn when firing the ability.
 */
var UDKExplosionLight DischargeLight;

/**
 * The ability-specific offset of the source location of the ability.
 * This can be thought as the displacement from the player's firing hand.
 */
var vector SourceOffset;

/** The name of the ability. */
var string AbilityName;

/**
 * The base damage that the ability deals.  This will be modified by player stats before 
 * the final damage is set.
 */
var float BaseDamage;

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

/**
 * This indicates that the ability can fire since the start fire animation is complete.
 */
var bool PlayedStartAnim;

/**
 * Indicates that the charge start anim is currently playing.  This is used to prevend ChargeTime from increasing during that time.
 */
var bool PlayingChargeStartAnim;

/**
 * Indicates that StopFire was called before the charge start anim could complete.  This allows the StopFire call to be queued, and
 * it will be called when the charge start anim finishes.
 */
var bool InterruptedChargeStartAnim;

/**
 * Indicates that the charge firing anim is currently playing.  This is used to prevend ChargeTime from increasing during that time.
 */
var bool PlayingChargeFireAnim;

/* Indicates that the ability is passive, and non-equippable. */
var bool IsPassive;


simulated function Tick(float dt)
{
	if (IsHolding)
	{
		HeldTime += dt;
		DeltaTime = dt;
	}
	else if (IsCharging && !PlayingChargeFireAnim)
	{
		ChargeTime += dt;
		
		if (ChargeParticles != None)
			ChargeParticles.SetFloatParameter('ChargeTime', ChargeTime);
			
		if (ChargeTime >= MaxCharge)
		{
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
		CanFire = false;
		PlayArmAnimation(ChargeStartAnim, 0.0, true);
		SetTimer(GetArmAnimLength(ChargeStartAnim) - 0.1, false, 'ChargeAnimComplete');
		PlayingChargeStartAnim = true;
		InterruptedChargeStartAnim = false;
	}
	
	if (CanFire && ArenaPawn(Instigator) != None && ArenaPawn(Instigator).Energy >= EnergyCost)
	{
		if (PlayedStartAnim || AP_Player(Instigator) == None)
		{
			if (CanHold && AP_Player(Instigator) != None)
				PlayArmAnimation(HoldingAnim, 0.0, true);
				
			super.StartFire(FireModeNum);
		}
		else
		{
			if (CanHold)
			{
				PlayArmAnimation(HoldStartAnim, 0.0);
				SetTimer(GetArmAnimLength(HoldStartAnim), false, 'FireAnimComplete');
			}
			else
			{
				PlayArmAnimation(FireStartAnim, 0.0);
				SetTimer(GetArmAnimLength(FireStartAnim), false, 'FireAnimComplete');
			}
		}
	}
}

/**
 * StopFire is called when the designated fire button is released.
 */
simulated function StopFire(byte FireModeNum)
{
	if (IsHolding)
	{
		IsHolding = false;
		HeldTime = 0;
		
		if (AP_Player(Instigator) != None)
			PlayArmAnimation(HoldEndAnim, 0.0);
			
		PlayedStartAnim = false;
	}
	else if (IsCharging && ChargeTime >= MinCharge)
	{
        CanFire = true;
		
		if (!PlayedStartAnim && AP_Player(Instigator) != None)
		{
			PlayArmAnimation(ChargeFireAnim, 0.0);
			SetTimer(GetArmAnimLength(ChargeFireAnim) - 0.1, false, 'ChargeFireAnimComplete');
			PlayingChargeFireAnim = true;
		}
		else
		{
			StartFire(0);
			IsCharging = false;
			ChargeTime = 0;
		}
		
        return;
	}
	else if (IsCharging && !CanFire)
	{
		IsCharging = false;
		CanFire = true;
		ChargeTime = 0;
		
		if (AP_Player(Instigator) != None)
			PlayArmAnimation(ChargeAbortAnim, 0.0);
		
		if (ChargeParticles != None)
				ChargeParticles.DeactivateSystem();
	}
	else if (PlayingChargeStartAnim)
	{
		InterruptedChargeStartAnim = true;
	}
	
	super.StopFire(FireModeNum);
}

simulated function FireAmmunition()
{
	super.FireAmmunition();
	
	if (CoolDown > 0 && !CanHold)
	{
		AbilityPlaySound(FireSound);
		EmitDischargeLight();
		CanFire = false;
		ClearPendingFire(0);
		SetTimer(ArenaPawn(Instigator).Stats.GetCooldownTime(CoolDown), false, 'ReactivateAbility');
		
		if (CanCharge)
		{
			if (AP_Player(Instigator) != None)
				PlayArmAnimation(ChargeEndAnim, 0.0);
			
			if (ChargeParticles != None)
				ChargeParticles.DeactivateSystem();
		}
		else
		{
			if (AP_Player(Instigator) != None)
				PlayArmAnimation(FireEndAnim, 0.0);
		}
			
		PlayedStartAnim = false;
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
	EmitSparks(RealImpact.HitLocation, RealImpact.HitActor);
	
	if (ArenaPawn(Instigator) != None)
		InstantHitDamage[0] = ArenaPawn(Instigator).Stats.GetDamageGiven(BaseDamage, InstantHitDamageTypes[0]);
	
	for (Idx = 0; Idx < ImpactList.Length; Idx++)
	{
		ProcessInstantHit(CurrentFireMode, ImpactList[Idx]);
	}
}

simulated function float GetArmAnimLength(name sequence)
{
	local AP_Player player;
	
	player = AP_Player(Instigator);

	if (player != None)
	{
		if (player.Arms == None)
			return 0;
			
		return player.Arms.GetAnimLength(sequence);
	}
	
	return 0;
}

simulated function PlayArmAnimation(name sequence, float duration, optional bool loop, optional SkeletalMeshComponent skelMesh)
{
	local AP_Player player;
	local AnimNodePlayCustomAnim node;

	if (WorldInfo.NetMode == NM_DedicatedServer || Instigator == None || !Instigator.IsFirstPerson())
		return;
	
	player = AP_Player(Instigator);

	if (player != None)
	{
		node = GetArmAnimNode();

		if (player.Arms == None || node == None)
			return;

		node.PlayCustomAnim(sequence, 1.0, , , loop);
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

simulated function FireAnimComplete()
{
	PlayedStartAnim = true;
	StartFire(0);
}

simulated function ChargeFireAnimComplete()
{
	PlayedStartAnim = true;
	PlayingChargeFireAnim = false;
	StartFire(0);
	IsCharging = false;
	ChargeTime = 0;
}

simulated function ChargeAnimComplete()
{
	if (InterruptedChargeStartAnim)
	{
		IsCharging = true;
		StopFire(0);
	}
	else
	{
		IsCharging = true;
		PlayArmAnimation(ChargingAnim, 0.0, true);
		EmitChargeParticles();
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

		IHBeam = WorldInfo.MyEmitterPool.SpawnEmitter(IHBeamTemplate, l, r);
		IHBeam.SetAbsolute(false, false, false);
		IHBeam.SetVectorParameter('HitLocation', hitLocation);
		IHBeam.SetVectorParameter('SourceLocation', l);
		IHBeam.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		IHBeam.bUpdateComponentInTick = true;
	}
}

simulated function EmitSparks(vector hitLocation, Actor hitActor)
{
	if (WorldInfo.NetMode != NM_DedicatedServer && SparkParticlesTemplate != None && hitActor != None)
	{
		SparkParticles = WorldInfo.MyEmitterPool.SpawnEmitter(SparkParticlesTemplate, hitLocation);
		SparkParticles.SetAbsolute(false, false, false);
		SparkParticles.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		SparkParticles.bUpdateComponentInTick = true;
		
		
	}
	
	if (WorldInfo.NetMode != NM_DedicatedServer && hitActor != None && !hitActor.bStatic)
	{
		if (SparkLight != None)
		{
			SparkLight.ResetLight();
			SparkLight.SetTranslation(hitLocation - hitActor.Location);
			hitActor.AttachComponent(SparkLight);	
		}
		else if (SLClass != None)
		{
			`log("Creating spark light");
			SparkLight = new(Outer) SLClass;
			SparkLight.SetTranslation(hitLocation - hitActor.Location);
			hitActor.AttachComponent(SparkLight);			
		}
	}
}

/**
 * Emits the particle system used for ability charging.
 */
simulated function EmitChargeParticles()
{
	local vector l;
	local rotator r;
	
	if (WorldInfo.NetMode != NM_DedicatedServer && ChargeParticlesTemplate != None)
	{
		if (ArenaPawn(Instigator) != None)
			ArenaPawn(Instigator).GetAbilitySourceOffset(l, r);
		
		r = Instigator.Controller.Rotation;
		l = l + (SourceOffset >> r);
		
		ChargeParticles = new class'ParticleSystemComponent';
		ChargeParticles.bAutoActivate = false;
		
		if (ArenaPawn(Instigator) != None)
			ArenaPawn(Instigator).AttachToAbilitySource(ChargeParticles);
			
		ChargeParticles.SetTemplate(ChargeParticlesTemplate);
		ChargeParticles.ActivateSystem();
	}
}

simulated function EmitDischargeLight()
{
	if (DischargeLight != None)
	{
		DischargeLight.ResetLight();
	}
	else if (DLClass != None)
	{
		DischargeLight = new(Outer) DLClass;
		
		if (ArenaPawn(Instigator) != None)
			ArenaPawn(Instigator).AttachToAbilitySource(DischargeLight);
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
	
	FireStartAnim=PlayerArmsAbilityOffHandStart
	FireEndAnim=PlayerArmsAbilityOffHandEnd
	ChargeStartAnim=PlayerArmsAbilityChargeStart
	ChargingAnim=PlayerArmsAbilityCharging
	ChargeFireAnim=PlayerArmsAbilityChargeFire
	ChargeEndAnim=PlayerArmsAbilityChargeEnd
	ChargeAbortAnim=PlayerArmsAbilityChargeAbort
	HoldStartAnim=PlayerArmsAbilityHoldStart
	HoldingAnim=PlayerArmsAbilityHolding
	HoldEndAnim=PlayerArmsAbilityHoldEnd
	
	InstantHitDamage[0]=0
	
	CanFire=true
	//ChargedHasFired=false
}