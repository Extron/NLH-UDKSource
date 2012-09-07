/*******************************************************************************
	ArenaPlayerController

	Creation date: 24/06/2012 14:17
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaPlayerController extends UDKPlayerController;

/* The current loadout that the player is using. */
var PlayerLoadout Loadout;

/* The viewpoint offset to use when aiming down the sights. */
var vector ADSOffset;

/* The desired ADS offset. */
var vector DesiredADSOffset;

/* The vector to use to accelerate the pawn in the next player tick. */
var vector RushDestination;

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
	
	if (ArenaPawn(Pawn) != None && Role < Role_Authority)
	{
		//rot += ArenaPawn(Pawn).GetRecoil();
	
		if (ArenaPawn(Pawn).ADS || Aiming)
		{
			loc += (ADSOffset >> rot);
		}
	}
}

exec function ADS()
{
	local float rem;
	
	DesiredADSOffset = WeaponBase(Pawn.Weapon).GetOpticsOffset();
	ADSDirection *= -1;
	Aiming = true;
	
	rem = GetRemainingTimeForTimer('AimingComplete');
	
	if (rem == -1)
		rem = 0;

	ClearTimer('AimingComplete');
	SetTimer(ArenaPawn(Pawn).Stats.GetADSSpeed() - rem, false, 'AimingComplete');
}

simulated function PlayerTick(float DeltaTime)
{
	super.PlayerTick(DeltaTime);
	
	if (Aiming)
	{
		ADSOffset += DesiredADSOffset * DeltaTime / ArenaPawn(Pawn).Stats.GetADSSpeed() * ADSDirection;
	}
}

simulated function ReplicatedEvent(name property)
{
	if (property == nameof(Pawn))
	{
		if (ArenaPawn(Pawn) != None)
		{
			`log("Pawn is not None");
		
			ArenaPawn(Pawn).Stats.SetInitialStats(ArenaPawn(Pawn), ArenaGRI(WorldInfo.GRI).Constants);
			
			if (Role < Role_Authority)
			{
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

defaultproperties
{
	InputClass=class'Arena.ArenaPlayerInput'
	
	Begin Object Class=PlayerLoadout Name=DefaultLoadout
		Begin Object Class=WeaponSchematic Name=DefaultSchematic
			WeaponBase=class'Wp_BasicRifleBase';
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