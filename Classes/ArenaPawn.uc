/*******************************************************************************
	ArenaPawn

	Creation date: 24/06/2012 14:21
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaPawn extends UDKPawn;


/* The list of active effects that the player has. */
var Array<StatusEffect> ActiveEffects;

/* The player's gameplay stats. */
var PlayerStats Stats;

/* The pawn's light environment */
var DynamicLightEnvironmentComponent LightEnvironment;

/* The player's currently equipped ability. */
var ArenaAbility ActiveAbility; 

/* The camera animation to play when the pawn is idle (not moving). */
var CameraAnim IdleCamAnim;

/* The camera animation to play when the pawn is walking. */
var CameraAnim WalkCamAnim;

/** 
 * The default anim set to use for the pawn's mesh.
 */
var AnimSet DefaultAnimSet;

/**
 * The skeletal control animation node that manages gun recoil.
 */
var GameSkelCtrl_Recoil RecoilControl;

/**
 * The name of the skeletal control animation node that manages gun recoil.
 */
var name RecoilControlName;

/* Stores the amount of energy the player currently has. */
var float Energy;

/* The maximum energy that the player has. */
var float EnergyMax;

/* The player's current stamina, used wore sprinting and jumping. */
var float Stamina;

/* The maximum stamina that the player has. */
var float StaminaMax;

/* A float variable to store health in. */
var float FHealth;

/* Indicates that the player can regenerate health at this time. */
var bool CanRegenHealth;

/* Indicates that the player can regenerate energy at this time. */
var bool CanRegenEnergy;

/* Indicates that the player can regenerate stamina at this time. */
var bool CanRegenStamina;

/* indicates that the pawn is aiming down the weapon sights. */
var bool ADS;

/* Indicates that the pawn is sprinting. */
var bool Sprinting;

/**
 * Indicates that this pawn is invisible.  This mainly deals with whether or not bots can see the pawn.
 */
var bool Invisible;

/**
 * Indicates that this pawn should not take any damage.
 */
var bool Invincible;

var bool initInv;

replication 
{ 
	if(bNetDirty) 
		Energy, FHealth, Stamina, Sprinting;
		
	if (bNetInitial)
		Stats, initInv;
}

function PossessedBy(Controller C, bool bVehicleTransition)
{
	super.PossessedBy(C, bVehicleTransition);
	
	if (PlayerController(C) != None)
		PlayerController(C).ResetCameraMode();
	
	if (Role == Role_Authority && WorldInfo.NetMode == NM_ListenServer)
	{
		InitInventory();
		initInv = False;
	}
}
	
/**
 * Calculates the player's camera location based on the location of the pawn.
 *
 * @param fDeltaTime - The time difference since the last update.
 * @param out_CamLoc - The resulting camera location.
 * @param out_CamRot - The relulting camera rotation.
 * @param out_FOV - The resulting FOV.
 * @returns Returns whether or not the pawn can modify the camera.
 */
simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
	GetActorEyesViewPoint(out_CamLoc, out_CamRot);
	return true;
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	Mesh.AnimSets[0] = DefaultAnimSet;
}


/** 
 * Ticks the pawn.
 *
 * @param dt - The amount of time that has passed since the last update.
 */
simulated function Tick(float dt)
{
	local float healthRate;
	local float energyRate;
	local float staminaRate;
	local int i;
	
	//super.Tick(dt);
	
	if (CanRegenHealth && Health < HealthMax) 
	{
		healthRate = Stats.GetHealingRate();
		FHealth = FHealth + 50 * healthRate * dt;
		
		Health = FHealth;
		
		if (Health > HealthMax)
		{
			Health = HealthMax;
			CanRegenHealth = false;
		}
	}
	
	if (CanRegenEnergy && Energy < EnergyMax) 
	{
		energyRate = Stats.GetEnergyRate();
		Energy = Energy + (energyRate / dt);
		
		if (Energy > EnergyMax)
		{
			Energy = EnergyMax;
			CanRegenEnergy = false;
		}
	}
	
	if (CanRegenStamina && Stamina < StaminaMax) 
	{
		staminaRate = Stats.GetStaminaRate();
		Stamina = Stamina + (staminaRate / dt);
		
		if (Stamina > StaminaMax)
		{
			Stamina = StaminaMax;
			CanRegenStamina = false;
		}
	}
	
	MovementSpeedModifier = Stats.GetMovementSpeed();
	
	if (Sprinting)
	{
		MovementSpeedModifier *= Stats.GetSprintSpeed();
		
		SpendStamina(dt * StaminaMax);
		
		if (Stamina <= 0)
		{
			StopSprint();
	}
		}
	
	if (ArenaWeapon(Weapon) != None)
	{
		PositionArms();
	}
	
	for (i = 0; i < ActiveEffects.Length; i++)
	{
		ActiveEffects[i].Tick(dt);
	}
	
	if (ArenaInventoryManager(InvManager) != None)
	{
		for (i = 0; i < ArenaInventoryManager(InvManager).Abilities.Length; i++)
		{
			ArenaInventoryManager(InvManager).Abilities[i].Tick(dt);
		}
	}
}

function bool DoJump(bool bUpdating)
{
	if (bJumpCapable && !bIsCrouched && !bWantsToCrouch && Physics == PHYS_Walking)
	{
		if (!bIsWalking)
			Velocity.Z = JumpZ * Stats.GetJumpZ();
			
		if (Base != None && !Base.bWorldGeometry && Base.Velocity.Z > 0.f)
		{
			Velocity.Z += Base.Velocity.Z;
		}
		
		SetPhysics(PHYS_Falling);
		
		return true;
	}
	
	return false;
}

simulated function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	if (!Invincible)
	{
		super.TakeDamage(Stats.GetDamageTaken(DamageAmount, DamageType), EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
		`log("Damage Type" @ DamageType @ "Amount" @ DamageAmount);
	}
}

simulated function NotifyTakeHit(Controller InstigatedBy, vector HitLocation, int Damage, class<DamageType> DamageType, vector Momentum,  Actor DamageCauser)
{
	super.NotifyTakeHit(InstigatedBy, HitLocation, Damage, DamageType, Momentum, DamageCauser);
	
	CanRegenHealth = false;
	SetTimer(Stats.GetRegenHealthDelay(), false, 'AllowRegenHealth');
}

simulated function HitWall(Vector HitNormal, Actor Wall, PrimitiveComponent WallComp)
{	
	super.HitWall(HitNormal, Wall, WallComp);
	
	if (IEnvObj(Wall) != None)
	{
		IEnvObj(Wall).TouchPawn(self);
	}
}

simulated function Bump(Actor other, PrimitiveComponent otherComp, Vector hitNormal)
{
	local int i;
	
	if (ArenaPawn(other) != None && ArenaInventoryManager(InvManager) != None)
	{
		for (i = 0; i < ArenaInventoryManager(InvManager).Abilities.Length; i++)
		{
			ArenaInventoryManager(InvManager).Abilities[i].ProcessHitPawn(ArenaPawn(other));
		}
	}
}


simulated function RagDoll()
{
	StartFallImpactTime = WorldInfo.TimeSeconds;
	bCanPlayFallingImpacts=true;
	//GotoState('FeigningDeath');

	// if we had some other rigid body thing going on, cancel it
	if (Physics == PHYS_RigidBody)
	{
		//@note: Falling instead of None so Velocity/Acceleration don't get cleared
		setPhysics(PHYS_Falling);
	}

	// Ensure we are always updating kinematic
	Mesh.MinDistFactorForKinematicUpdate = 0.0;

	SetPawnRBChannels(TRUE);
	Mesh.ForceSkelUpdate();

	// Move into post so that we are hitting physics from last frame, rather than animated from this
	Mesh.SetTickGroup(TG_PostAsyncWork);

	bBlendOutTakeHitPhysics = false;

	PreRagdollCollisionComponent = CollisionComponent;
	CollisionComponent = Mesh;

	// Turn collision on for skelmeshcomp and off for cylinder
	CylinderComponent.SetActorCollision(false, false);
	Mesh.SetActorCollision(true, true);
	Mesh.SetTraceBlocking(true, true);

	SetPhysics(PHYS_RigidBody);
	Mesh.PhysicsWeight = 1.0;

	// If we had stopped updating kinematic bodies on this character due to distance from camera, force an update of bones now.
	if( Mesh.bNotUpdatingKinematicDueToDistance )
	{
		Mesh.UpdateRBBonesFromSpaceBases(TRUE, TRUE);
	}

	Mesh.PhysicsAssetInstance.SetAllBodiesFixed(FALSE);
	Mesh.bUpdateKinematicBonesFromAnimation=FALSE;

	// Set all kinematic bodies to the current root velocity, since they may not have been updated during normal animation
	// and therefore have zero derived velocity (this happens in 1st person camera mode).
	Mesh.SetRBLinearVelocity(Velocity, false);

	//FeignDeathStartTime = WorldInfo.TimeSeconds;
	// reset mesh translation since adjustment code isn't executed on the server
	// but the ragdoll code uses the translation so we need them to match up for the
	// most accurate simulation
	Mesh.SetTranslation(vect(0,0,1) * BaseTranslationOffset);
	// we'll use the rigid body collision to check for falling damage
	Mesh.ScriptRigidBodyCollisionThreshold = MaxFallSpeed;
	Mesh.SetNotifyRigidBodyCollision(true);
	Mesh.WakeRigidBody();

	if (Role == ROLE_Authority)
	{
		//SetTimer(0.15, true, 'FeignDeathDelayTimer');
	}
}

simulated function Recover()
{
	`log("Recovering");
	
	RestorePreRagdollCollisionComponent();
	Mesh.PhysicsWeight = 0.0f;
	Mesh.PhysicsAssetInstance.SetAllBodiesFixed(TRUE);
	Mesh.bUpdateKinematicBonesFromAnimation=TRUE;
	Mesh.MinDistFactorForKinematicUpdate = default.Mesh.MinDistFactorForKinematicUpdate;
	SetPawnRBChannels(FALSE);

	if (Physics == PHYS_RigidBody)
		setPhysics(PHYS_Falling);
}

simulated function SetPawnRBChannels(bool bRagdollMode)
{
	if(bRagdollMode)
	{
		Mesh.SetRBChannel(RBCC_Pawn);
		Mesh.SetRBCollidesWithChannel(RBCC_Default,TRUE);
		Mesh.SetRBCollidesWithChannel(RBCC_Pawn,TRUE);
		Mesh.SetRBCollidesWithChannel(RBCC_Vehicle,TRUE);
		Mesh.SetRBCollidesWithChannel(RBCC_Untitled3,FALSE);
		Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume,TRUE);
	}
	else
	{
		Mesh.SetRBChannel(RBCC_Untitled3);
		Mesh.SetRBCollidesWithChannel(RBCC_Default,FALSE);
		Mesh.SetRBCollidesWithChannel(RBCC_Pawn,FALSE);
		Mesh.SetRBCollidesWithChannel(RBCC_Vehicle,FALSE);
		Mesh.SetRBCollidesWithChannel(RBCC_Untitled3,TRUE);
		Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume,FALSE);
	}
}

function AddVelocity(vector newVel, vector hitLoc, class<DamageType> damageType, optional TraceHitInfo hitInfo)
{
	if (Role < Role_Authority)
		ServerAddVelocity(newVel, hitLoc, damageType, hitInfo);
		
	super.AddVelocity(newVel, hitLoc, damageType, hitInfo);
}

reliable server function ServerAddVelocity(vector newVel, vector hitLoc, class<DamageType> damageType, optional TraceHitInfo hitInfo)
{
	super.AddVelocity(newVel, hitLoc, damageType, hitInfo);
}

simulated function Recoil()
{
	`log("Recoil" @ RecoilControl);
	
	if (RecoilControl != None)
		RecoilControl.bPlayRecoil = true;
}

simulated function rotator GetRecoil()
{
	if (ArenaWeapon(Weapon) != None)
	{
		return ArenaWeapon(Weapon).GetRecoilRotation(self);
	}
	
	return rot(0, 0, 0);
}

/*
 * Starts the player's active ability fire routine.
 */
simulated function StartFireAbility()
{
	if (ActiveAbility != None)
	{
		ActiveAbility.StartFire(0);
	}
}

simulated function StopFireAbility()
{
	if (ActiveAbility != None)
	{
		ActiveAbility.StopFire(0);
	}
}

simulated function StartSprint()
{
	if (!Sprinting && Stamina > 0 && VSize(Velocity) > 0)
	{
		Sprinting = true;
		
		ServerStartSprint();
		
		GoToState('Running');
	}
}

simulated function StopSprint()
{
	Sprinting = false;
	
	ServerStopSprinting();
	
	GoToState('Walking');
}

reliable server function ServerStartSprint()
{
	Sprinting = true;
}

reliable server function ServerStopSprinting()
{
	Sprinting = false;
}

simulated function ReloadWeapon()
{
	if (ArenaWeapon(Weapon) != None && ArenaWeapon(Weapon).CanReload())
	{
		ArenaWeapon(Weapon).ReloadWeapon();
	}
}

simulated function AimDownSights()
{
	ADS = true;
}

simulated function Melee()
{
	local vector x, y, z, hitloc;
	local ArenaPawn target;

	GetAxes(GetViewRotation(), x, y, z);

	foreach VisibleCollidingActors(class'ArenaPawn', target, Stats.GetMeleeRange(), Location)
	{
		hitloc = target.Location + (target.Location - Location);

		target.TakeDamage(Stats.GetMeleeDamage(), ArenaPlayerController(Owner), hitloc, Normal(x), None);

		//momentum = (traget.Location - Location) * 1000/target.Mass;
		//Other.Velocity += momentum;
	}
}

simulated function RebootElectronics(ArenaPawn pawn)
{
	//TODO: Reboot electronics of the player here.
}

simulated function PositionArms()
{
}

simulated function ReplicatedEvent(name property)
{
	if (property == nameof(InvManager))
	{
		if (initInv)
		{
			InitInventory();
			initInv = False;
		}
	}
}

function InitInventory()
{
}

function ArenaWeapon CreateWeapon(WeaponSchematic schematic)
{
	local ArenaWeaponBase ArenaWeaponBase;
	local Wp_Stock stock;
	local Wp_Barrel barrel;
	local Wp_Muzzle muzzle;
	local Wp_Optics optics;
	local Wp_SideAttachment side;
	local Wp_UnderAttachment under;
	
	ArenaWeaponBase = spawn(schematic.ArenaWeaponBase, Self, , Location, Rotation);
	ArenaWeaponBase.WeaponName = schematic.WeaponName;
	
	stock = spawn(schematic.WeaponStock, ArenaWeaponBase, , ArenaWeaponBase.Location, ArenaWeaponBase.Rotation);
	barrel = spawn(schematic.WeaponBarrel, ArenaWeaponBase, , ArenaWeaponBase.Location, ArenaWeaponBase.Rotation);
	muzzle = spawn(schematic.WeaponMuzzle, ArenaWeaponBase, , ArenaWeaponBase.Location, ArenaWeaponBase.Rotation);
	optics = spawn(schematic.WeaponOptics, ArenaWeaponBase, , ArenaWeaponBase.Location, ArenaWeaponBase.Rotation);
	side = spawn(schematic.WeaponSideAttachment, ArenaWeaponBase, , ArenaWeaponBase.Location, ArenaWeaponBase.Rotation);
	under = spawn(schematic.WeaponUnderAttachment, ArenaWeaponBase, , ArenaWeaponBase.Location, ArenaWeaponBase.Rotation);
	
	ArenaWeaponBase.AttachStock(stock);
	ArenaWeaponBase.AttachBarrel(barrel);
	ArenaWeaponBase.AttachMuzzle(muzzle);
	ArenaWeaponBase.AttachOptics(optics);
	ArenaWeaponBase.AttachSide(side);
	ArenaWeaponBase.AttachUnder(under);
	
	return ArenaWeaponBase;
}

simulated function SpendEnergy(float EnergyAmount)
{
	local float cost;
	
	cost = Stats.GetEnergyCost(EnergyAmount);
	
	if (cost > 0)
	{
		Energy -= cost;
		CanRegenEnergy = false;
		SetTimer(Stats.GetRegenEnergyDelay(), false, 'AllowRegenEnergy');
	}
}

simulated function SpendStamina(float StaminaAmount)
{
	local float cost;
	
	cost = Stats.GetStaminaCost(StaminaAmount);
	
	if (cost > 0)
	{
		Stamina -= cost;
		CanRegenStamina = false;
		SetTimer(Stats.GetRegenStaminaDelay(), false, 'AllowRegenStamina');
	}
}

simulated function bool CanSpendEnergy(float energyAmount)
{
	return Stats.GetEnergyCost(energyAmount) <= Energy;
}

/*
 * Adds a status effect to the player. 
 */
simulated function AddEffect(StatusEffect effect)
{
	effect.ActivateEffect(Self);
	ActiveEffects.AddItem(effect);
}

simulated function RemoveEffect(StatusEffect effect)
{
	ActiveEffects.RemoveItem(effect);
}

simulated function AddStatMod(PlayerStatModifier mod)
{
	Stats.AddModifier(mod);
}

simulated function AllowRegenHealth()
{
	CanRegenHealth = true;
	FHealth = Health;
}

simulated function AllowRegenEnergy()
{
	CanRegenEnergy = true;
}

simulated function AllowRegenStamina()
{
	CanRegenStamina = true;
}

function bool HasStatus(ArenaPlayerController player, string effectName, out StatusEffect effect)
{
	local int i;
	
	if (ActiveEffects.Length > 0)
	{
		for (i = 0; i < ActiveEffects.Length; i++)
		{
			if (ActiveEffects[i].EffectName == effectName && player == ActiveEffects[i].Affector)
			{
				effect = ActiveEffects[i];
				return true;
			}
		}
	}
	
	effect = None;
	return false;
}

/**
 * Gets the location that abilities will fire from.  Preferrably, this will be the location of the
 * player's right or left hand (as per player handedness).
 */
function GetAbilitySourceOffset(out vector l, out rotator r)
{	
	l = vect(0, 0, 0);
	r = rot(0, 0 , 0);
}

function GetWeaponSourceOffset(out vector l, out rotator r)
{	
	l = vect(0, 0, 0);
	r = rot(0, 0 , 0);
}

function name GetWeaponHandSocket()
{
	return 'RightHandSocket';
}

exec function KillMe()
{
	TakeDamage(Health, ArenaPlayerController(Owner), Location, vect(0, 0, 0), None);
}

exec function SetInvisible(bool value)
{
	Invisible = value;
}

exec function SetInvincible(bool value)
{
	Invincible = value;
}

exec function CurrentState()
{
	`log("My current state is:" @ GetStateName());
}

exec function SetCoolDownMod(float mod)
{
	Stats.Values[PSVAbilityCooldownFactor] = mod;
}

state Idle
{
	simulated event BeginState(name prev)
	{
		if (ArenaPlayerController(Controller) != None)
		{
			ArenaPlayerController(Controller).ClientPlayCameraAnim(IdleCamAnim, , , 0.25, 0.25, true, false);
		}
	}
	
	simulated event EndState(name next)
	{
		if (ArenaPlayerController(Controller) != None)
		{
			ArenaPlayerController(Controller).ClientStopCameraAnim(IdleCamAnim);
		}
	}
}

state Walking
{
	simulated event BeginState(name prev)
	{
		if (ArenaPlayerController(Controller) != None)
		{
			ArenaPlayerController(Controller).ClientPlayCameraAnim(WalkCamAnim, , , 0.25, 0.25, true, false);
		}
	}
	
	simulated event EndState(name next)
	{
		if (ArenaPlayerController(Controller) != None)
		{
			ArenaPlayerController(Controller).ClientStopCameraAnim(WalkCamAnim);
		}
	}
}

state Running
{
	simulated event BeginState(name prev)
	{
		if (ArenaPlayerController(Controller) != None)
		{
			ArenaPlayerController(Controller).ClientPlayCameraAnim(WalkCamAnim, 3, 1.2, 0.35, 0.35, true, false);
		}
	}
	
	simulated event EndState(name next)
	{
		if (ArenaPlayerController(Controller) != None)
		{
			ArenaPlayerController(Controller).ClientStopCameraAnim(WalkCamAnim);
		}
	}
}

defaultproperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bSynthesizeSHLight=TRUE
		bIsCharacterLightEnvironment=TRUE
		bUseBooleanEnvironmentShadowing=FALSE
	End Object
	Components.Add(MyLightEnvironment)
	LightEnvironment=MyLightEnvironment
	
	DefaultAnimSet=AnimSet'AC_Player.Animations.PlayerAnim'
	
	// TODO: This is just a temp mesh so that Unreal doesn't freak out that we don't have one.
	Begin Object Class=SkeletalMeshComponent Name=WPawnSkeletalMeshComponent
		//SkeletalMesh=SkeletalMesh'AC_Player.Meshes.PlayerMesh'
		PhysicsAsset=PhysicsAsset'AC_Player.Physics.PlayerMeshPhysics'
		Translation=(X=-10,Y=0,Z=0)
		Scale=0.95
		bCacheAnimSequenceNodes=FALSE
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		bOwnerNoSee=false
		CastShadow=true
		BlockRigidBody=TRUE
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=TRUE
		bUpdateKinematicBonesFromAnimation=true
		bCastDynamicShadow=true
		RBChannel=RBCC_Untitled3
		RBCollideWithChannels=(Untitled3=true)
		LightEnvironment=MyLightEnvironment
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=FALSE
		AnimTreeTemplate=AnimTree'AC_Player.Animations.PlayerAnimTree'
		AnimSets[0]=AnimSet'AC_Player.Animations.PlayerAnim'
		bHasPhysicsAssetInstance=true
		TickGroup=TG_PreAsyncWork
		bChartDistanceFactor=true
		MinDistFactorForKinematicUpdate=0.2
		RBDominanceGroup=20
		bUseOnePassLightingOnTranslucency=TRUE
		bPerBoneMotionBlur=true
	End Object
	Mesh=WPawnSkeletalMeshComponent
	Components.Add(WPawnSkeletalMeshComponent)
	
	Begin Object Class=PlayerStats Name=NewStats
		Values[PSVHealthRegenDelay]=10
	End Object
	Stats=NewStats
	
	IdleCamAnim=CameraAnim'CameraAssets.Animations.IdleAnimation'
	WalkCamAnim=CameraAnim'CameraAssets.Animations.WalkAnimation'
	ADS=false
	bDirectHitWall=true
	InventoryManagerClass=class'Arena.ArenaInventoryManager'
	HealthMax=1000
	Health=1000
	FHealth=1000
	EnergyMax=1000
	Energy=1000
	Stamina=1000
	StaminaMax=1000
	
	EyeHeight=64
	
	CrouchHeight=40.0
	CrouchRadius=21.0
	bCanCrouch=true
	
	Invisible=false
	initInv=True
}