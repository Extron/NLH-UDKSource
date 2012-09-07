/*******************************************************************************
	ArenaWeapon

	Creation date: 08/07/2012 13:00
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaWeapon extends UDKWeapon
	dependson(WeaponStats);

/* Indicates what type of projectiles a weapon base fires.  This will affect what components cam be used with the base. */
enum WeaponType
{
	WTRifle,
	WTShotgun,
	WTRocketLauncher,
	WTGrenadeLauncher,
	WTHardLightRifle,
	WTBeamRifle,
	WTPlasmaRifle
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

/** A list of names of the reload animations to use when the weapon reloads. */
var array<name> ReloadAnims;

/** A list of names of animations to use when cycling the weapon's bolt. */
var array<name> CycleBoltAnims;

/** The animations to play when firing the weapon. */
var array<name> FireAnims;

/** A list of animations to play from when the weapon is being equipped. */
var array<name> EquipAnims;

/** The type of the weapon, which determines what kind of projectile the weapon fires and what components can be used on it. */
var WeaponType Type;

/** The size of the weapon.  This determines pojectile size and power, and what components can be used on it. */
var WeaponSize Size;

/** The weapon's fire mode. */
var FireMode Mode;

/** The stats of the weapon. */
var WeaponStats Stats;

/** The sound of the ability firing. */
var SoundCue FireSound;

/** The weapon's offset on the screen. */
var vector ViewOffset;

/** The recoil acceleration. */
var vector RecoilAccel;

/** The recoil velocity. */
var vector RecoilVel;

/** The recoil position. */
var vector RecoilPos;

/** The name of the weapon. */
var string WeaponName;

/** This keeps track of the inaccuracy of the weapon caused by firing it.  It will increase the more the 
    weapon is fired, and will only decrease once the weapon is not fired for a short time. */ 
var float Bloom;

/** Indicates that the weapon is reloading. */
var bool Reloading;

/** Indicates that the weapon is being equipped. */
var bool Equipping;

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

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	Stats.Initialize(self, ArenaPawn(Instigator).Stats.Constants);
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

function ConsumeAmmo(byte FireModeNum)
{
	Clip -= AmmoPerShot;
	
	if (Clip < 0)
	{
		Clip = 0;
	}
}

simulated function FireAmmunition()
{
	FireWeapon();
	
	super.FireAmmunition();
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
	EndTrace = (StartTrace + vector(GetAdjustedAim(StartTrace)) * GetTraceRange()) << Stats.GetInaccuracyShift();

	// Perform shot
	RealImpact = CalcWeaponFire(StartTrace, EndTrace, ImpactList);

	if (Role == ROLE_Authority)
	{
		SetFlashLocation(RealImpact.HitLocation);
	}

	for (Idx = 0; Idx < ImpactList.Length; Idx++)
	{
		ProcessInstantHit(CurrentFireMode, ImpactList[Idx]);
	}
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
	AttachWeaponTo(Instigator.Mesh);
	EquipWeapon();
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
		EnsureWeaponOverlayComponentLast();
		SetHidden(false);
		Mesh.SetLightEnvironment(pawn.LightEnvironment);
		
		//if (GetHand() == HAND_Hidden)
		//{
			//pawn.ArmsMesh[0].SetHidden(true);
			//pawn.ArmsMesh[1].SetHidden(true);
		//}
	}
	else
	{
		SetHidden(True);
		if (pawn != None)
		{
			Mesh.SetLightEnvironment(pawn.LightEnvironment);
			pawn.ArmsMesh[0].SetHidden(true);
			pawn.ArmsMesh[1].SetHidden(true);
		}
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
	
	`log("Equipping weapon.");
}

/**
 * This function aligns the gun model in the world
 */
simulated event SetPosition(UDKPawn Holder)
{
	local vector T;
	local rotator R;
	
	if (!Holder.IsFirstPerson())
		return;
	
	T.Z = Holder.EyeHeight;
	T = T + (ViewOffset >> Holder.Controller.Rotation);
	T = T + Holder.Location;
	
	if (Holder.Controller != None)
	{
		R = Holder.Controller.Rotation;
	}
	
	SetLocation(T);
	SetRotation(R);
	SetBase(Holder);
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

simulated function FireWeapon()
{
	local float duration;
	local int anim;
	
	if (FireAnims.Length > 0)
	{	
		duration = FireInterval[0];
		anim = rand(FireAnims.Length);
		
		PlayWeaponAnimation(FireAnims[anim], duration);
	}
	
	Bloom += Stats.GetBloomCost();
	
	if (Bloom > Stats.Constants.GetStatMax("Bloom"))
	{
		Bloom = Stats.Constants.GetStatMax("Bloom");
	}

	RecoilAccel.X = 0;
	RecoilAccel.Y = FRand() - 0.5;
	RecoilAccel.Z = FRand();
	RecoilAccel = Normal(RecoilAccel) * 1000;
	
	if (FireSound != None )
	{
		MakeNoise(1.0);
		WeaponPlaySound(FireSound);
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

simulated function EquipWeapon()
{
	local float normDuration;
	local float actualDuration;
	local SkeletalMeshComponent skelMesh;
	local int anim;
	
	if (EquipAnims.Length > 0)
	{
		Equipping = true;
		anim = rand(EquipAnims.Length);
		skelMesh = SkeletalMeshComponent(Mesh);
		
		normDuration = skelMesh.GetAnimLength(EquipAnims[anim]);
		actualDuration = normDuration * Stats.GetEquipSpeed();
		
		if (ArenaPawn(Owner) != None)
			actualDuration *= ArenaPawn(Owner).Stats.GetEquipSpeed();
			
		PlayWeaponAnimation(EquipAnims[anim], actualDuration);
		SetTimer(actualDuration, false, 'OnEquippingAnimEnd');
	}
	else
	{
		OnEquippingAnimEnd();
	}
}

simulated function rotator GetRecoilRotation(Pawn holder)
{
	local vector x, y, z;

	GetAxes(holder.Controller.Rotation, x, y, z);

	return rotator(RecoilPos);
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

exec function DisplayPosition()
{
	if (Mesh != None)
	{
		`log("Mesh Position" @ Mesh.GetPosition());
		`log("Pawn Position" @ Instigator.Location);
	}
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

defaultproperties
{
	Begin Object Class=UDKSkeletalMeshComponent Name=FirstPersonMesh
		DepthPriorityGroup=SDPG_PostProcess
		bOnlyOwnerSee=true
		bOverrideAttachmentOwnerVisibility=true
		bCastDynamicShadow=false
		CastShadow=false
	End Object
	Mesh=FirstPersonMesh
	
	Begin Object Class=WeaponStats Name=NewStats
	End Object
	Stats=NewStats
	
	FireInterval(0)=1
	FiringStatesArray(0)=WeaponFiring
	Spread(0)=1
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
	
	AmmoPerShot=1
}