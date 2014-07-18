/*******************************************************************************
	ArenaWeapon

	Creation date: 08/07/2012 13:00
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaWeapon extends UDKWeapon
	dependson(WeaponStats);

/**
 * Indicates what type of projectiles a weapon base fires.  This will affect what components cam be used with the base. 
 */
enum WeaponType
{
	WTRifle,
	WTShotgun,
	WTRocketLauncher,
	WTGrenadeLauncher,
	WTHardLightRifle,
	WTBeamRifle,
	WTPlasmaRifle,
	WTRailGun
};

enum WeaponSize
{
	WSHand,
	WSSmall,
	WSRegular,
	WSLarge,
	WSHeavy
};

enum FireMode
{
	FMBoltAction,
	FMSemiAuto,
	FMBurst,
	FMFullAuto,
	FMBeam
};

/**
 * Allows the weapon to have its own set of movement animations.
 */
var AnimSet MovementAnimSet;

/**
 * The animation set that contains every animation specific to the weapon, such as reloading, cycling, etc.
 */
var AnimSet WeaponAnimSet;

/**
 * The animation set for the first person player when this weapon is equipped.
 */
var AnimSet PlayerAnimSet;

/** A list of names of the reload animations to use when the weapon reloads. */
var array<name> ReloadAnims;

/** A list of names of animations to use when cycling the weapon's bolt. */
var array<name> CycleAnims;

/** The animations to play when firing the weapon. */
var array<name> FireAnims;

/** A list of animations to play from when the weapon is being equipped. */
var array<name> EquipAnims;

/**
 * A list of melee animations that the weapon can use.
 */
var array<name> MeleeAnims;

/**
 * A list of all fire modes the weapon can be in.
 */
var array<FireMode> FireModes;

/**
 * The allowed fire mode types for the base.
 */
var array<FireMode> AllowedFireModes;

/**
 * The clip mesh component that the weapon uses to draw the clip/magazine.
 */
var UDKSkeletalMeshComponent ClipMesh;

/** The type of the weapon, which determines what kind of projectile the weapon fires and what components can be used on it. */
var WeaponType Type;

/** The size of the weapon.  This determines pojectile size and power, and what components can be used on it. */
var WeaponSize Size;

/** The stats of the weapon. */
var WeaponStats Stats;

/** The sound of the ability firing. */
var SoundCue FireSound;

/**
 * The sound to play when the weapon is cycled.
 */
var SoundCue CycleSound;

/** The weapon's fire mode. */
var int Mode;
 
/**
 * The particle system template to use when drawing the beam for an instant hit shot.
 */
var ParticleSystem IHBeamTemplate;

/**
 * The instance of the IH Beam particle system.
 */
var ParticleSystemComponent IHBeam;

/**
 * The muzzle flash particle system.  This can be overridden by muzzles if they specify it.
 */
var ParticleSystemComponent MuzzleFlash;

/**
 * The light for the muzzle flash.
 */
var	UDKExplosionLight MuzzleFlashLight;

/** The weapon's offset on the screen. */
var vector ViewOffset;

/** The recoil acceleration. */
var vector RecoilAccel;

/** The recoil velocity. */
var vector RecoilVel;

/** The recoil position. */
var vector RecoilPos;

/**
 * The deviation from the bullet path in which any bots inside are alerted of a near hit.
 */
var vector SweepExtent;

/** The name of the weapon. */
var string WeaponName;

/**
 * The base damage that the weapon deals.  This will be modified by player and weapon stats before 
 * the final damage is set.
 */
var float BaseDamage;

/** This keeps track of the inaccuracy of the weapon caused by firing it.  It will increase the more the 
    weapon is fired, and will only decrease once the weapon is not fired for a short time. */ 
var float Bloom;

/** 
 * The current temperature of the weapon.  Some weapons, such as beam rifles, can overheat if used to frequently.
 */
var float Temperature;

/**
 * The maximum temperature that the weapon can handle before overheating.
 */
var float CriticalTemperature;

/**
 * The amount of time needed to pass in between cycling.  For example, semi-auto weapons
 * can only fire again after this time has passed.
 */
var float CycleTime;

/**
 * The range at which we check for bots that were near the path of the bullet.
 */
var float SweepRange;

/**
 * The idea range of the weapon.
 */
var float IdealRange;

/** Indicates that the weapon is reloading. */
var bool Reloading;

/** Indicates that the weapon is being equipped. */
var bool Equipping;

/**
 * Indicates that the weapon is being cycled (only used with bolt action).
 */
var bool Cycling;

/**
 * Indicates that the weapon can not fire due to overheating.
 */
var bool Overheated;

/**
 * Indicates that we have ended firing.
 */
var bool EndedFire;

/**
 * The number of bullets to fire for a burst.
 */
var int BurstCount;

/**
 * Helps keep track of the number of bullets that have been fired for burst fire modes.
 */
var int BulletsFired;

/** The max amount of ammo the player can carry for this weapon. */
var int MaxAmmo;

/** The current amount of ammo the player has for the weapon. */
var int Ammo;

/** The max amount of ammo per clip for the weapon. */
var int MaxClip;

/** The amount of ammo left in the current clip. */
var int Clip;

/** The amount of ammo that is used in one shot.  This is largely only used if the weapon is a burst fire weapon. */
var int AmmoPerShot;

var bool StatsInitialized;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	if (!StatsInitialized && Instigator != None)
	{
		Stats.Initialize(self);	
		StatsInitialized = true;
	}
}

simulated function InitializeStats()
{
	Stats.Initialize(self);
	
	StatsInitialized = true;
}

simulated function Tick(float dt)
{
	super.Tick(dt);
	
	if (Bloom > 0)
	{
		Bloom -= 50 * dt;
		
		if (Bloom < 0)
			Bloom = 0;
	}
	
	if (Temperature > 0)
	{
		Temperature -= Stats.GetCooldownRate() * dt;
		
		if (Temperature < 0)
			Temperature = 0;
	}
	
	RecoilAccel += (-10 * RecoilPos - 15 * RecoilVel);
	
	RecoilVel += RecoilAccel * dt;
	RecoilPos += RecoilVel * dt;
	
	RecoilAccel = vect(0, 0, 0);
}

simulated function StartFire(byte FireModeNum)
{
	if (Clip > 0 && !Reloading && !Equipping)
	{
		super.StartFire(FireModeNum);
	}
	else if (Clip == 0 && Ammo > 0)
	{
		GoToState('WeaponReloading');
	}
}

simulated function StopFire(byte FireModeNum)
{
	if (!EndedFire)
	{
		BulletsFired = 0;
		EndedFire = True;
	
		CycleWeapon();
	}
	
	super.StopFire(FireModeNum);
}

function ConsumeAmmo(byte FireModeNum)
{
	Clip -= AmmoPerShot;
	
	if (Clip < 0)
	{
		Clip = 0;
		StopFire(FireModeNum);
	}
}

simulated function FireAmmunition()
{
	if (EndedFire)
		return;

	if (FireModes[Mode] == FMFullAuto || (FireModes[Mode] == FMSemiAuto && BulletsFired < 1) || (FireModes[Mode] == FMBurst && BulletsFired < BurstCount) || (FireModes[Mode] == FMBoltAction && !Cycling))
	{
		FireWeapon();
	
		BulletsFired++;
		super.FireAmmunition();
	}
}

/*
 * This function checks to see if the weapon has any ammo available for a given fire mode.
 *
 * @param	FireModeNum The Fire Mode to Test For
 * @param	Amount [Optional] Check to see if this amount is available.
 * @return	true if ammo is available for Firemode FireModeNum.
 */
simulated function bool HasAmmo(byte FireModeNum, optional int Amount)
{
	return Clip > 0;
}

simulated function bool ShouldRefire()
{
	if (EndedFire || Clip <= 0 || Overheated)
		return false;
	 
	if (FireModes[Mode] == FMFullAuto)
		return true;
	else if (FireModes[Mode] == FMSemiAuto || FireModes[Mode] == FMBoltAction)
		return false;
	else if (FireModes[Mode] == FMBurst)
		return BulletsFired < BurstCount;
}

/**
 * Returns interval in seconds between each shot, for the firing state of FireModeNum firing mode.
 *
 * @param	FireModeNum	fire mode
 * @return	Period in seconds of firing mode
 */
simulated function float GetFireInterval(byte FireModeNum)
{
	return Stats.Values[WSVRateOfFire];
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

	SweepBullet(StartTrace, Normal(EndTrace - StartTrace), SweepExtent, FMin(SweepRange, VSize(RealImpact.HitLocation - StartTrace)));
	
	if (Role == ROLE_Authority)
	{
		SetFlashLocation(RealImpact.HitLocation);	
	}

	EmitIHBeam(RealImpact.HitLocation);
	
	if (ArenaPawn(Instigator) != None)
		InstantHitDamage[0] = ArenaPawn(Instigator).Stats.GetDamageGiven(BaseDamage * Stats.GetDamageModifier(), InstantHitDamageTypes[0]);
	
	for (Idx = 0; Idx < ImpactList.Length; Idx++)
	{
		ProcessInstantHit(CurrentFireMode, ImpactList[Idx]);
	}
}

simulated function Projectile ProjectileFire()
{
	local Projectile projectile;
	local vector start, direction;
	
	projectile = super.ProjectileFire();
	
	if (projectile != None)
		projectile.Damage = BaseDamage * Stats.GetDamageModifier();
	
	start = Instigator.GetWeaponStartTraceLocation();
	direction = Normal(vector(GetAdjustedAim(start)));
	
	SweepBullet(start, direction, SweepExtent, SweepRange);
	
	return projectile;
}

simulated function PlayFireEffects( byte FireModeNum, optional vector HitLocation )
{
	EmitMuzzleFlash();
}

simulated function rotator AddSpread(rotator BaseAim)
{
	return Stats.GetInaccuracyShift();
}

/**
 * Sets the timing for equipping a weapon.
 * The WeaponEquipped event is trigged when expired
 */
simulated function TimeWeaponEquipping()
{
	if (AP_Player(Instigator) != None)
		AttachWeaponTo(AP_Player(Instigator).RightArm, AP_Player(Instigator).GetWeaponHandSocket());
		
	EquipWeapon(ArenaPawn(Instigator));
}

/**
 * Attach Weapon Mesh, Weapon MuzzleFlash and Muzzle Flash Dynamic Light to a SkeletalMesh
 *
 * @param	who is the pawn to attach to
 */
simulated function AttachWeaponTo(SkeletalMeshComponent MeshCpnt, optional Name SocketName)
{
	local ArenaPawn pawn;
	
	pawn = ArenaPawn(Instigator);
	
	// Attach 1st Person Wp_Muzzle Flashes, etc,
	if (Instigator.IsFirstPerson())
	{
		AttachComponent(Mesh);
		AttachClip();
		EnsureWeaponOverlayComponentLast();
		SetHidden(false);
		
		SetBase(Owner, , MeshCpnt, SocketName);
		MeshCpnt.AttachComponentToSocket(Mesh, SocketName);
	}
	else
	{
		SetHidden(True);
		
		if (pawn != None)
			AttachComponent(Mesh);
	}

	//SetWeaponOverlayFlags(pawn);

	// Spawn the 3rd Person Attachment
	if (Role == ROLE_Authority && pawn != None)
	{
		//pawn.CurrentWeaponAttachmentClass = AttachmentClass;
		//if (WorldInfo.NetMode == NM_ListenServer || WorldInfo.NetMode == NM_Standalone || (WorldInfo.NetMode == NM_Client && Instigator.IsLocallyControlled()))
		//{
			//pawn.WeaponAttachmentChanged();
		//}
	}

	//SetSkin(ArenaPawn(Instigator).ReplicatedBodyMaterial);
}

function AttachClip()
{
	local name socket;
	
	socket = 'ClipSocket';

	if (ClipMesh != None)
	{
		if (SkeletalMeshComponent(Mesh).GetSocketByName(socket) != None)
			SkeletalMeshComponent(Mesh).AttachComponentToSocket(ClipMesh, socket);
	}
}

function AttachWeapon(LightEnvironmentComponent lightEnv)
{
	AttachComponent(Mesh);
	AttachClip();
	EnsureWeaponOverlayComponentLast();
	SetHidden(false);
	Mesh.SetLightEnvironment(lightEnv);
	
	if (ClipMesh != None)
		ClipMesh.SetLightEnvironment(lightEnv);
}

/**
 * This function aligns the gun model in the world
 */
simulated event SetPosition(UDKPawn Holder)
{
	ArenaPawn(Holder).PositionArms();
}

simulated function PlayArmAnimation(name sequence, float duration, optional bool loop, optional SkeletalMeshComponent skelMesh)
{
	local AP_Player player;
	
	if( WorldInfo.NetMode == NM_DedicatedServer || Instigator == None || !Instigator.IsFirstPerson())
		return;
	
	player = AP_Player(Instigator);

	if (player != None)
		player.PlayAnimation(sequence, duration, loop);
}

simulated function AnimNodeSequence GetArmAnimNodeSeq()
{
	local AP_Player player;

	player = AP_Player(Instigator);
	
	if (player != None && player.RightArm != None)
		return AnimNodeSequence(player.RightArm.Animations);

	return None;
}

simulated function PlayWeaponAnimation(Name sequence, float duration, optional bool loop, optional SkeletalMeshComponent skelMesh)
{
	local AnimNodeSequence WeapNode;

	if (WorldInfo.NetMode == NM_DedicatedServer)
		return;

	if (skelMesh == None)
		skelMesh = SkeletalMeshComponent(Mesh);

	WeapNode = GetWeaponAnimNodeSeq();
	
	if(skelMesh == None || WeapNode == None)
		return;
	
	if (duration <= 0.0)
		duration = WeapNode.GetAnimPlaybackLength();
		
	if (duration <= 0.0)
		return;

	WeapNode.SetAnim(sequence);
	WeapNode.PlayAnim(loop, duration / WeapNode.GetAnimPlaybackLength());
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
simulated function WeaponPlaySound(SoundCue Sound)
{
	// if we are a listen server, just play the sound.  It will play locally
	// and be replicated to all other clients.
	if(Sound != None && Instigator != None)
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
		GetMuzzleSocketLocRot(l, r);		
		
		IHBeam = WorldInfo.MyEmitterPool.SpawnEmitter(IHBeamTemplate, l);
		IHBeam.SetAbsolute(false, false, false);
		IHBeam.SetVectorParameter('HitLocation', hitLocation);
		IHBeam.SetVectorParameter('SourceLocation', l);
		IHBeam.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		IHBeam.bUpdateComponentInTick = true;
	}
}

simulated function EmitMuzzleFlash()
{
	local ParticleSystem muzzleFlashTemplate;
	local class<UDKExplosionLight> lightClass;
	
	muzzleFlashTemplate = GetMuzzeFlashParticleTemplate();
	lightClass = GetMuzzleFlashLightClass();
	
	if (muzzleFlashTemplate != None)
	{
		MuzzleFlash = new class'ParticleSystemComponent';
		MuzzleFlash.bAutoActivate = false;
		
		AttachToMuzzleSocket(MuzzleFlash);
		
		MuzzleFlash.SetTemplate(muzzleFlashTemplate);
		MuzzleFlash.ActivateSystem();
	}
	
	if ( MuzzleFlashLight != None )
	{
		MuzzleFlashLight.ResetLight();
	}
	else if (lightClass != None)
	{
		MuzzleFlashLight = new(Outer) lightClass;
		AttachToMuzzleSocket(MuzzleFlashLight);
	}

}

/**
 * To help AI know when they are getting shot at, sweep out a trace to check for bots near the bullet path.
 */
simulated function SweepBullet(vector start, vector direction, vector extent, float range)
{
	local AP_Bot iter;
	local vector hitLoc, hitNorm;
	
	foreach TraceActors(class'Arena.AP_Bot', iter, hitLoc, hitNorm, Normal(direction) * range, start, extent)
	{
		iter.ShotAt(self, Instigator, hitLoc, direction);
	}
}

/**
 * Computes the location of the muzzle socket for the weapon.  Is designed to be overridden in subclasses.
 */
simulated function GetMuzzleSocketLocRot(out vector l, out rotator r)
{
	l = vect(0, 0, 0);
	r = rot(0, 0, 0);
}

/**
 * Determines if the weapon has any type of optics that allow aiming down sights.
 */
simulated function bool CanADS()
{
	return false;
}

simulated function bool OnlyAlterWeaponFOV()
{
	return false;
}

/**
 * Allows weapon optics to modify things like depth of field when the player aims down sights.
 */
simulated function BlurADS(UberPostProcessEffect effect)
{
}

/**
 * Attaches a primitive component to the weapon's muzzle.  Is designed to be overridden in subclasses.
 */
simulated function AttachToMuzzleSocket(ActorComponent component)
{
}

simulated function ParticleSystem GetMuzzeFlashParticleTemplate()
{
	return None;
}

simulated function class<UDKExplosionLight> GetMuzzleFlashLightClass()
{
	return None;
}

simulated function SoundCue GetFireSound()
{
	return FireSound;
}

/**
 * Computes the location of the grip socket for the weapon.  Is designed to be overridden in subclasses.
 */
simulated function GetGripSocketLocRot(out vector l, out rotator r)
{
	l = vect(0, 0, 0);
	r = rot(0, 0, 0);
}

simulated function float GetIdealRange()
{
	return IdealRange;
}

simulated function FireWeapon()
{
	local SoundCue fs;
	local int anim;
	
	if (FireAnims.Length > 0)
	{
		anim = rand(FireAnims.Length);
		PlayWeaponAnimation(FireAnims[anim], 0.0);
	}
	
	Bloom += Stats.GetBloomCost();
	Temperature += Stats.GetHeatCost();
	
	if (Bloom > class'GlobalGameConstants'.static.GetStatMax("Bloom"))
		Bloom = class'GlobalGameConstants'.static.GetStatMax("Bloom");
		
	if (CriticalTemperature > 0 && Temperature > CriticalTemperature)
	{
		Temperature = CriticalTemperature;
		GotoState('WeaponOverheated');
	}

	if (ArenaPawn(Instigator) != None)
		ArenaPawn(Instigator).Recoil();
		
	RecoilAccel.X = 0;
	RecoilAccel.Y = FRand() - 0.5;
	RecoilAccel.Z = FRand();
	RecoilAccel = Normal(RecoilAccel) * 1000;
	
	fs = GetFireSound();
	
	if (fs != None )
	{
		MakeNoise(1.0);
		WeaponPlaySound(fs);
	}
}

simulated function ReloadWeapon()
{
	//This is the duration that the animation normally takes.
	local float normDuration;
	local float actualDuration;
	local SkeletalMeshComponent skelMesh;
	local int anim;
	
	if (ReloadAnims.Length > 0)
	{
		Reloading = true;
		anim = rand(ReloadAnims.Length);
		skelMesh = SkeletalMeshComponent(Mesh);
		
		normDuration = skelMesh.GetAnimLength(ReloadAnims[anim]);
		actualDuration = normDuration * Stats.GetReloadSpeed();
		
		if (ArenaPawn(Owner) != None)
			actualDuration *= ArenaPawn(Owner).Stats.GetReloadSpeed();
			
		PlayWeaponAnimation(ReloadAnims[anim], actualDuration);
		SetTimer(actualDuration, false, 'OnReloadingAnimEnd');
	}
	else
	{
		OnReloadingAnimEnd();
	}
}

simulated function CycleWeapon()
{
	local float normDuration;
	local float actualDuration;
	local SkeletalMeshComponent skelMesh;
	local int anim;
	
	`log("Cycling weapon");
	
	if (CycleAnims.Length > 0)
	{
		anim = rand(CycleAnims.Length);
		skelMesh = SkeletalMeshComponent(Mesh);
		
		normDuration = skelMesh.GetAnimLength(CycleAnims[anim]);
		actualDuration = normDuration * Stats.GetCycleSpeed();
		
		if (ArenaPawn(Owner) != None)
			actualDuration *= ArenaPawn(Owner).Stats.GetCycleSpeed();
			
		PlayWeaponAnimation(CycleAnims[anim], actualDuration);
		
		SetTimer(actualDuration, false, 'ReactivateWeapon');
	}
	else
	{
		WeaponPlaySound(CycleSound);
		SetTimer(CycleTime, false, nameof(ReactivateWeapon));
	}
}

simulated function EquipWeapon(ArenaPawn pawn)
{
	local float normDuration;
	local float actualDuration;
	local SkeletalMeshComponent skelMesh;
	local int anim;
		
	if (AP_Player(pawn) != None)
		skelMesh = AP_Player(pawn).RightArm;

	if (EquipAnims.Length > 0)
	{		
		`log("Equipping weapon");
	
		Equipping = true;
		anim = rand(EquipAnims.Length);
		
		normDuration = skelMesh.GetAnimLength(EquipAnims[anim]);
		actualDuration = normDuration * Stats.GetEquipSpeed();

		if (pawn != None)
			actualDuration *= pawn.Stats.GetEquipSpeed();
					
		`log("Normal duration" @ normDuration @ "Actual duration" @ actualDuration);
		
		PlayArmAnimation(EquipAnims[anim], actualDuration);
		SetTimer(actualDuration, false, 'OnEquippingAnimEnd');
	}
	else
	{
		OnEquippingAnimEnd();
	}
}

simulated function SetFireMode(FireMode fMode)
{
	FireModes.Length = 0;
	FireModes.AddItem(fMode);
	Mode = 0;
}

simulated function SetFireModes(array<FireMode> modes, optional int selectedMode = 0)
{
	local int i;
	
	FireModes.Length = 0;
	
	for (i = 0; i < modes.Length; i++)
	{
		if (AllowedFireModes.Find(modes[i]) > -1)
			FireModes.AddItem(modes[i]);
	}
		
	Mode = selectedMode;
}

simulated function CycleFireMode()
{
	Mode = (Mode + 1) % FireModes.Length;
}

simulated function ReactivateWeapon()
{
	EndedFire = false;
}

simulated function HideWeapon(bool hidden)
{
	Mesh.SetHidden(hidden);
	
	if (AP_Player(Instigator) != None)
	{
		AP_Player(Instigator).RightArm.SetHidden(hidden);
		AP_Player(Instigator).LeftArm.SetHidden(hidden);
	}
	
	if (ClipMesh != None)
		ClipMesh.SetHidden(hidden);
}

simulated function SetWeaponFOV(float angle)
{
	`log("Setting weapon FOV" @ angle);
	
	/*if (AP_Player(Instigator) != None)
	{
		UDKSkeletalMeshComponent(AP_Player(Instigator).RightArm).SetFOV(angle);
		UDKSkeletalMeshComponent(AP_Player(Instigator).LeftArm).SetFOV(angle);
	}*/
	
	if (ClipMesh != None)
		ClipMesh.SetFOV(angle);
	
	UDKSkeletalMeshComponent(Mesh).SetFOV(angle);
}

simulated function SetWeaponScale(float scale)
{
	Mesh.SetScale(scale);
}

simulated function rotator GetRecoilForce()
{
	local rotator force;
	
	force.Pitch = (Stats.Values[WSVRecoil] * 6) * 65536;
	force.Yaw = (Stats.Values[WSVRecoil] * 1.5) * 65536 * ((FRand() > 0.5) ? -1 : 1);
	
	return force;
}

simulated function float GetAvgReloadSpeed()
{
	local SkeletalMeshComponent skelMesh;
	local float average;
	local int i;
	
	skelMesh = SkeletalMeshComponent(Mesh);
	
	for (i = 0; i < ReloadAnims.Length; i++)
	{
		average += skelMesh.GetAnimLength(ReloadAnims[i]);
	}
	
	if (ReloadAnims.Length > 0)
		average /= ReloadAnims.Length;
	
	return average * Stats.GetReloadSpeed();
}

simulated function float GetAvgEquipSpeed()
{
	local SkeletalMeshComponent skelMesh;
	local float average;
	local int i;
	
	skelMesh = SkeletalMeshComponent(Mesh);
		
	for (i = 0; i < EquipAnims.Length; i++)
	{
		average += skelMesh.GetAnimLength(EquipAnims[i]);
	}
	
	if (EquipAnims.Length > 0)
		average /= EquipAnims.Length;
	
	return average * Stats.GetEquipSpeed();
}

simulated function AddMaxAmmo()
{
	Ammo = MaxAmmo;
}

simulated function bool CanReload()
{
	return !Reloading && Clip < MaxClip && Ammo > 0;
}

/**
 * Adds ammo to the weapon by inserting a new clipful of ammo into the weapon.
 */
simulated function OnReloadingAnimEnd()
{
	if (Ammo >= MaxClip)
	{
		if (Clip > 0)
			Clip = MaxClip + 1;
		else
			Clip = MaxClip;
		
		
		Ammo -= MaxClip;
	}
	else
	{
		Clip = Ammo;
		Ammo = 0;
	}
	
	Reloading = False;
	GoToState('Active');
}

simulated function OnEquippingAnimEnd()
{
	Equipping = false;
	GoToState('Active');
}

simulated function Overheat()
{
}

simulated function CoolDown()
{
}

/**
 * State Reloading
 * The weapon is currently reloading, running reloading animations and putting ammo into the weapon.
 * The weapon cannot be fired while in this state, though there are exceptions to this rule.
 */
simulated state WeaponReloading
{
	simulated event BeginState(name prev)
	{
		if (!Reloading && Ammo > 0)
		{
			ReloadWeapon();
		}
	}
}

simulated state WeaponOverheated
{
	simulated event BeginState(name prev)
	{
		SetTimer(Stats.GetOverheatDelay(), false, 'CooledDown');
		Overheat();
		Overheated = true;
	}
	
	simulated function StartFire(byte FireModeNum)
	{
		//Cannot fire while overheated.
	}
	
	simulated function CooledDown()
	{
		Overheated = false;
		CoolDown();
		GotoState('Active');
	}
}

defaultproperties
{
	Begin Object Class=UDKSkeletalMeshComponent Name=FirstPersonMesh
		DepthPriorityGroup=SDPG_PostProcess
		bOnlyOwnerSee=true
		bOverrideAttachmentOwnerVisibility=true
		bCastDynamicShadow=false
		CastShadow=false
		bOwnerNoSee=false
		BlockZeroExtent=true
	End Object
	Mesh=FirstPersonMesh
	
	Begin Object Class=UDKSkeletalMeshComponent Name=Clip
		DepthPriorityGroup=SDPG_PostProcess
		bOnlyOwnerSee=true
		bOverrideAttachmentOwnerVisibility=true
		bCastDynamicShadow=false
		CastShadow=false
		bOwnerNoSee=false
		BlockZeroExtent=true
	End Object
	ClipMesh=Clip
	
	Begin Object Class=WeaponStats Name=NewStats
	End Object
	Stats=NewStats
	
	MeleeAnims[0]=Arms1PMelee1
	MeleeAnims[1]=Arms1PMelee2
	MeleeAnims[3]=Arms1PMelee3
	
	FireInterval(0)=1
	FiringStatesArray(0)=WeaponFiring
	Spread(0)=1
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
	SweepRange=1000
	SweepExtent=(X=300,Y=300,Z=300)
	
	AmmoPerShot=1
}