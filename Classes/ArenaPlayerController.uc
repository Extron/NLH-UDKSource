/*******************************************************************************
	ArenaPlayerController

	Creation date: 24/06/2012 14:17
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaPlayerController extends UDKPlayerController;



/* The current loadout that the player is using. */
var PlayerLoadout Loadout;

/**
 * The default location (without ADS).
  */
var vector DefaultLoc;

/* The viewpoint offset to use when aiming down the sights. */
var vector ADSOffset;

/* The desired ADS offset. */
var vector DesiredADSOffset;

/* The vector to use to accelerate the pawn in the next player tick. */
var vector RushDestination;

/** Gets the amount of time since the player has been dead. */
var float TimeDead;

/* Indicates that the player is in the process of aiming down the sights. */
var bool Aiming;

/* The direction in which we are aiming. */
var int ADSDirection;

var bool FiringAbility;

/* Indicates that the pawn will be accelerated on the next player tick. */
var bool AccelPawn;

simulated function ReceivedGameClass(class<GameInfo> GameClass)
{
	super.ReceivedGameClass(GameClass);
	
	ArenaGRI(WorldInfo.GRI).Constants.Initialize();
	
	if (Role < Role_Authority)
	{
		ServerInitializeGameConstants();
	}
}

function Possess(Pawn newPawn, bool bVehicleTransition)
{
	if (Role == Role_Authority && WorldInfo.NetMode == NM_ListenServer)
	{
		ArenaPawn(newPawn).Stats.SetInitialStats(ArenaPawn(newPawn), ArenaGRI(WorldInfo.GRI).Constants);
				
		Loadout.InitializeLoadout(self);
	}
	
	super.Possess(newPawn, bVehicleTransition);

	newPawn.GoToState('Idle');
}

function AdjustFOV(float DeltaTime )
{
	if ( FOVAngle != DesiredFOV )
	{
		if ( FOVAngle > DesiredFOV )
			FOVAngle = FOVAngle - FMax(7, 0.4 * DeltaTime * (FOVAngle - DesiredFOV));
		else
			FOVAngle = FOVAngle - FMin(-7, 0.4 * DeltaTime * (FOVAngle - DesiredFOV));
		if ( Abs(FOVAngle - DesiredFOV) <= 10 )
			FOVAngle = DesiredFOV;
	}
	
	FOV(FOVAngle);
}

simulated function GetPlayerViewPoint(out vector loc, out Rotator rot)
{
	super.GetPlayerViewPoint(loc, rot);
	
	DefaultLoc = loc;
	
	if (ArenaPawn(Pawn) != None && (Role < Role_Authority || WorldInfo.NetMode == NM_ListenServer))
	{
		//rot += ArenaPawn(Pawn).GetRecoil();
	
		if (ArenaPawn(Pawn).ADS || Aiming)
		{
			loc += (ADSOffset >> rot);
		}
	}
}

function CheckJumpOrDuck()
{
	super.CheckJumpOrDuck();
	
	if(Pawn != None && (Pawn.Physics != PHYS_Falling && Pawn.bCanCrouch))
	{
		Pawn.ShouldCrouch(bDuck != 0);
	}
}

exec function ADS()
{
	local float rem;

	DesiredADSOffset = ArenaWeaponBase(Pawn.Weapon).GetOpticsOffset(ArenaPawn(Pawn));
	ADSOffset = DesiredADSOffset;
	ADSDirection *= -1;
	Aiming = true;
	
	if (ADSDirection > 0)
		DesiredFOV = FOVAngle / ArenaWeaponBase(Pawn.Weapon).GetZoomLevel();
	else
		DesiredFOV = DefaultFOV;
		
	rem = GetRemainingTimeForTimer('AimingComplete');
	
	if (rem == -1)
		rem = 0;

	ClearTimer('AimingComplete');
	SetTimer(ArenaPawn(Pawn).Stats.GetADSSpeed() - rem, false, 'AimingComplete');
}

simulated function PlayerTick(float DeltaTime)
{
	local float t;
	
	super.PlayerTick(DeltaTime);
	
	if (Aiming)
	{
		`log("Aiming" @ ADSOffset);
		t = 1 - GetRemainingTimeForTimer('AimingComplete') / ArenaPawn(Pawn).Stats.GetADSSpeed();
		//ADSOffset = DesiredADSOffset * t;
	}
}

simulated function ReplicatedEvent(name property)
{
	if (property == nameof(Pawn))
	{
		if (ArenaPawn(Pawn) != None)
		{		
			ArenaPawn(Pawn).Stats.SetInitialStats(ArenaPawn(Pawn), ArenaGRI(WorldInfo.GRI).Constants);
				
			Loadout.InitializeLoadout(self);
	
			if (Role < Role_Authority)
			{
				`log("Replicating event");
				ServerInitializePlayerStats();
			}
		}
	}
}

reliable server function ServerInitializePlayerStats()
{
	if (ArenaPawn(Pawn) != None)
	{
		ArenaPawn(Pawn).Stats.SetInitialStats(ArenaPawn(Pawn), ArenaGRI(WorldInfo.GRI).Constants);
	}
}

reliable server function ServerInitializeGameConstants()
{
	ArenaGRI(WorldInfo.GRI).Constants.Initialize();
}

simulated function AimingComplete()
{
	Aiming = false;
	ArenaPawn(Pawn).ADS = !ArenaPawn(Pawn).ADS;
}

state PlayerWalking
{
	simulated function ProcessMove(float delta, vector newAccel, eDoubleClickDir doubleClickMove, rotator deltaRot)
	{
		super.ProcessMove(delta, newAccel, doubleClickMove, deltaRot);
		
		if (newAccel == vect(0, 0, 0))
		{
			Pawn.GoToState('Idle');
		}
		else
		{
			if (!ArenaPawn(Pawn).Sprinting)
			{
				Pawn.GoToState('Walking');
			}
		}
		
	}
}

state Dead
{
	event BeginState(name prev)
	{
		if ((Pawn != None) && (Pawn.Controller == self))
			Pawn.Controller = None;

		Pawn = None;
		FOVAngle = DesiredFOV;
		Enemy = None;
		bFrozen = true;
		bPressedJump = false;
		
		FindGoodView();
	    SetTimer(ArenaGRI(WorldInfo.GRI).RespawnTime, false);
		CleanOutSavedMoves();
	}
	
	event Timer()
	{
		if (!bFrozen)
			return;

		bFrozen = false;
		bPressedJump = false;
		
		if (ArenaGRI(WorldInfo.GRI).ForceRespawn)
				ServerReStartPlayer();
	}
	
	exec function StartFire( optional byte FireModeNum )
	{
		if (bFrozen)
		{
			if (!IsTimerActive() || GetTimerCount() > ArenaGRI(WorldInfo.GRI).RespawnTime)
				bFrozen = false;
				
			return;
		}

		if (ArenaGRI(WorldInfo.GRI).AllowFastRespawn)
			ServerReStartPlayer();
	}
}

defaultproperties
{
	InputClass=class'Arena.ArenaPlayerInput'
	
	Begin Object Class=PlayerLoadout Name=DefaultLoadout
		Begin Object Class=WeaponSchematic Name=DefaultSchematic
			ArenaWeaponBase=class'Wp_BasicRifleBase';
			WeaponStock=class'Wp_S_CheapStock';
			WeaponBarrel=class'Wp_B_BasicRifleBarrel';
			WeaponMuzzle=class'Wp_M_BasicRifleMuzzle';
			WeaponOptics=class'Wp_O_CheapIronSights';
			WeaponSideAttachment=class'Wp_SA_NoSideAttachment';
			WeaponUnderAttachment=class'Wp_UA_NoUnderAttachment';
			WeaponName="Cheap Rifle"
		End Object
		Weapon=DefaultSchematic
		LoadoutName="Default Loadout"
	End Object
	Loadout=DefaultLoadout
	
	ADSDirection=-1
}