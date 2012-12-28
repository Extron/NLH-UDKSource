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
		`log("We are on a listen server.");

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
		ArenaWeapon(Weapon).SetPosition(Self);
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
	`log("Damage after stat" @ Stats.GetDamageTaken(DamageAmount, DamageType));
	
	super.TakeDamage(Stats.GetDamageTaken(DamageAmount, DamageType), EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
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
	if (!Sprinting && Stamina > 0)
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
	local vector x, y, z, hitloc, momentum;
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

simulated function ReplicatedEvent(name property)
{
	if (property == nameof(InvManager))
	{
		`log("Replicated InvManager" @ ArenaInventoryManager(InvManager));
		
		if (initInv)
		{
			InitInventory();
			initInv = False;
		}
	}
}

function InitInventory()
{
	local ArenaWeapon newWeapon;
	
	if (ArenaPlayerController(Owner) != None && ArenaPlayerController(Owner).Loadout != None && ArenaPlayerController(Owner).Loadout.Weapon != None)
	{
		newWeapon = CreateWeapon(ArenaPlayerController(Owner).Loadout.Weapon);
	}
	
	if (ArenaInventoryManager(InvManager) != None)
	{	
		if (newWeapon != None)
		{
			InvManager.AddInventory(newWeapon);
			InvManager.NextWeapon();
		}
		
		CreateInventory(class'Arena.Ab_ChargedShock', true);
		ArenaInventoryManager(InvManager).NextAbility();
	}
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

exec function KillMe()
{
	TakeDamage(Health, ArenaPlayerController(Owner), Location, vect(0, 0, 0), None);
}

exec function CurrentState()
{
	`log("My current state is:" @ GetStateName());
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
			`log("Sprint State");
			ArenaPlayerController(Controller).ClientPlayCameraAnim(WalkCamAnim, 3, 1.2, 0.35, 0.35, true, false);
		}
	}
	
	simulated event EndState(name next)
	{
		if (ArenaPlayerController(Controller) != None)
		{
			`log("End Sprint State");
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
	
	// TODO: This is just a temp mesh so that Unreal doesn't freak out that we don't have one.
	Begin Object Class=SkeletalMeshComponent Name=WPawnSkeletalMeshComponent
		bCacheAnimSequenceNodes=FALSE
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		bOwnerNoSee=true
		CastShadow=true
		BlockRigidBody=TRUE
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=TRUE
		bUpdateKinematicBonesFromAnimation=true
		bCastDynamicShadow=true
		Translation=(Z=8.0)
		RBChannel=RBCC_Untitled3
		RBCollideWithChannels=(Untitled3=true)
		LightEnvironment=MyLightEnvironment
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=FALSE
		AnimTreeTemplate=AnimTree'CH_AnimHuman_Tree.AT_CH_Human'
		bHasPhysicsAssetInstance=true
		TickGroup=TG_PreAsyncWork
		bChartDistanceFactor=true
		MinDistFactorForKinematicUpdate=0.2
		//bSkipAllUpdateWhenPhysicsAsleep=TRUE
		RBDominanceGroup=20
		Scale=1.075
		// Nice lighting for hair
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
	
	initInv=True
}