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
 * The player's save data.
 */
var PlayerData SaveData;

/**
 * The HUD settings for the player.
 */
var PlayerHUDSettings HUDSettings;

/**
 * The class that the player is using.
 */
var PlayerClass PClass;

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

/**
 * The time needed to aim down sights.
 */
var float ADSTime;

/**
 * The amount of time that the player has been aiming for.
 */
var float ADSCounter;

var float OldFOV;

var float FOVTime;

var float FOVCounter;

/** Gets the amount of time since the player has been dead. */
var float TimeDead;

/* Indicates that the player is in the process of aiming down the sights. */
var bool Aiming;

/* The direction in which we are aiming. */
var int ADSDirection;

var bool FiringAbility;

/* Indicates that the pawn will be accelerated on the next player tick. */
var bool AccelPawn;

simulated function PostBeginPlay()
{
	local string filename;
	
	super.PostBeginPlay();
	
	if (Role < Role_Authority || (Role == Role_Authority && WorldInfo.NetMode == NM_ListenServer))
	{
		`log("Loading player save data file.");
		if (PlayerReplicationInfo.PlayerName == "")
			PlayerReplicationInfo.PlayerName = "Nameless";
			
		filename = PlayerReplicationInfo.PlayerName $ "_data.bin";
		
		SaveData = new class'Arena.PlayerData';
		
		if (!(class'Engine'.static.BasicLoadObject(SaveData, filename, true, class'Arena.PlayerData'.const.FileVersion)))
		{
			`log("No save data detected.  Creating a new file.");
			
			if (!(class'Engine'.static.BasicSaveObject(SaveData, filename, true, class'Arena.PlayerData'.const.FileVersion)))
				`log("File save failed.");
		}
		
		SaveData.Initialize();
	}		
}

simulated function ReceivedGameClass(class<GameInfo> GameClass)
{
	super.ReceivedGameClass(GameClass);
	
	ArenaGRI(WorldInfo.GRI).Constants.Initialize();
	
	if (Role < Role_Authority )
		ServerInitializeGameConstants();
}

function Possess(Pawn newPawn, bool bVehicleTransition)
{
	if (Role == Role_Authority && WorldInfo.NetMode == NM_ListenServer)
	{
		ArenaPawn(newPawn).Stats.SetInitialStats(ArenaPawn(newPawn));

		PClass = new Loadout.AbilityClass;
		PClass.Owner = self;
		
		ArenaPawn(newPawn).AddStatMod(PClass.Mod);
	}
	
	super.Possess(newPawn, bVehicleTransition);

	newPawn.GoToState('Idle');
}

function SetFOV(float NewFOV)
{
	SetFOVWithTime(NewFOV, 0.25);
}

function SetFOVWithTime(float NewFOV, float time)
{
	DesiredFOV = NewFOV;
	OldFOV = FOVAngle;
	FOVTime = time;
}

function AdjustFOV(float DeltaTime )
{
	if (FOVAngle != DesiredFOV && FOVTime > 0)
	{		
		FOVCounter += DeltaTime;
		
		FOVAngle = Lerp(OldFOV, DesiredFOV, FOVCounter / FOVTime); 
		
		if (FOVCounter >= FOVTime)
		{
			FOVAngle = DesiredFOV;
			FOVTime = 0;
			FOVCounter = 0;
		}
	}
	
	if ((Aiming || ArenaPawn(Pawn).ADS) && ArenaWeapon(Pawn.Weapon).OnlyAlterWeaponFOV())
		ArenaWeapon(Pawn.Weapon).SetWeaponFOV(FOVAngle);
	else
		FOV(FOVAngle);
}

simulated function GetPlayerViewPoint(out vector loc, out Rotator rot)
{
	super.GetPlayerViewPoint(loc, rot);
	
	DefaultLoc = loc;
	
	if (Pawn == None)
		return;
		
	if (ArenaPawn(Pawn).ADS && !Aiming)
		ADSOffset = ArenaWeaponBase(Pawn.Weapon).GetOpticsOffset(ArenaPawn(Pawn));
	else if (Aiming && ADSDirection > 0)
		ADSOffset = ArenaWeaponBase(Pawn.Weapon).GetOpticsOffset(ArenaPawn(Pawn)) * ADSCounter / ADSTime;
	else if (Aiming && ADSDirection < 0)
		ADSOffset = ArenaWeaponBase(Pawn.Weapon).GetOpticsOffset(ArenaPawn(Pawn)) * (1 - ADSCounter / ADSTime);
	else
		ADSOffset = vect(0, 0, 0);
	 
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
	local UberPostProcessEffect UberEffect;
	local LocalPlayer PC;
	
	if (ArenaWeapon(Pawn.Weapon).CanADS())
	{
		ADSDirection *= -1;
		
		if (ADSDirection > 0)
			DesiredADSOffset = ArenaWeaponBase(Pawn.Weapon).GetOpticsOffset(ArenaPawn(Pawn));
		else
			DesiredADSOffset = vect(0, 0, 0);
			
		//ADSOffset = DesiredADSOffset;

		if (ADSCounter > 0)
			ADSTime = ADSCounter;
		else
			ADSTime = ArenaPawn(Pawn).Stats.GetADSSpeed();	
			
		if (ADSDirection > 0)
		{
			SetFOVWithTime(FOVAngle / ArenaWeaponBase(Pawn.Weapon).GetZoomLevel(), ADSTime);
			
			PC = LocalPlayer(Player);
	
			if(PC != none && PC.PlayerPostProcess != none && ArenaWeapon(Pawn.Weapon) != None)
			{
				UberEffect = UberPostProcessEffect(PC.PlayerPostProcess.FindPostProcessEffect('Uber'));
				
				if(UberEffect != none)
					ArenaWeapon(Pawn.Weapon).BlurADS(UberEffect);
			}
		}
		else
		{
			SetFOVWithTime(DefaultFOV, ADSTime);
			
			PC = LocalPlayer(Player);
	
			if(PC != none && PC.PlayerPostProcess != none)
			{
				UberEffect = UberPostProcessEffect(PC.PlayerPostProcess.FindPostProcessEffect('Uber'));
				
				if(UberEffect != none)
				{
					UberEffect.FocusDistance = 0;
					UberEffect.MaxNearBlurAmount = 0;
					UberEffect.MaxFarBlurAmount = 0;
				}
			}
		}
			
		Aiming = true;
	}
}

simulated function PlayerTick(float dt)
{
	super.PlayerTick(dt);
	
	if (Aiming)
	{
		ADSCounter += dt;

		if (ADSCounter >= ADSTime)
		{
			ADSCounter = 0;
			Aiming = false;
			ArenaPawn(Pawn).ADS = !ArenaPawn(Pawn).ADS;
		}
	}
}

simulated function ReplicatedEvent(name property)
{
	if (property == nameof(Pawn))
	{
		if (ArenaPawn(Pawn) != None)
		{
			ArenaPawn(Pawn).Stats.SetInitialStats(ArenaPawn(Pawn));
				
			PClass = new Loadout.AbilityClass;
			PClass.Owner = self;
		
			ArenaPawn(Pawn).AddStatMod(PClass.Mod);
	
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
		ArenaPawn(Pawn).Stats.SetInitialStats(ArenaPawn(Pawn));
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

function bool PerformedUseAction()
{
	local bool ret;
	
	ret = super.PerformedUseAction();
	
	if (!ret && ArenaPawn(Pawn).NearestInterObject != None)
	{
		ArenaPawn(Pawn).NearestInterObject.InteractWith(Pawn);
		ret = true;
	}
	
	return ret;
}

simulated function AwardBBTokens(int tokens)
{
	SaveData.BBData.Tokens += tokens;
	
	if (Pawn != None && PRI_BotBattle(Pawn.PlayerReplicationInfo) != None)
		PRI_BotBattle(Pawn.PlayerReplicationInfo).AwardTokens(tokens);
}

simulated function SpendBBTokens(int tokens)
{
	SaveData.BBData.Tokens -= tokens;
	
	if (Pawn != None && PRI_BotBattle(Pawn.PlayerReplicationInfo) != None)
		PRI_BotBattle(Pawn.PlayerReplicationInfo).SpendTokens(tokens);
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
		{
			ServerReStartPlayer();
		}
	}
	
	exec function StartFire( optional byte FireModeNum )
	{
		if (ArenaGRI(WorldInfo.GRI).AllowFastRespawn || !bFrozen)
			ServerReStartPlayer();
	}
	
	function PlayerMove(float DeltaTime)
	{
		local vector X,Y,Z;
		local rotator DeltaRot, ViewRotation;

		if ( !bFrozen )
		{
			if ( bPressedJump )
			{
				StartFire( 0 );
				bPressedJump = false;
			}
			GetAxes(Rotation,X,Y,Z);
			// Update view rotation.
			ViewRotation = Rotation;
			// Calculate Delta to be applied on ViewRotation
			DeltaRot.Yaw	= PlayerInput.aTurn;
			DeltaRot.Pitch	= PlayerInput.aLookUp;
			ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
			SetRotation(ViewRotation);
			if ( Role < ROLE_Authority ) // then save this move and replicate it
					ReplicateMove(DeltaTime, vect(0,0,0), DCLICK_None, rot(0,0,0));
		}

		ViewShake(DeltaTime);
	}
}

defaultproperties
{
	InputClass=class'Arena.ArenaPlayerInput'
	
	Begin Object Class=PlayerLoadout Name=DefaultLoadout
		Begin Object Class=WeaponSchematic Name=DefaultSchematic
			ArenaWeaponBase=class'Wp_BasicRifleBase';
			WeaponStock=class'Wp_S_WoodStock';
			WeaponBarrel=class'Wp_B_ShortRailedBarrel';
			WeaponMuzzle=class'Wp_M_NoMuzzle';
			WeaponOptics=class'Wp_O_CheapIronSights';
			WeaponSideAttachment=class'Wp_SA_NoSideAttachment';
			WeaponUnderAttachment=class'Wp_UA_Shotgun';
			WeaponName="Cheap Rifle"
		End Object
		Weapon=DefaultSchematic
		LoadoutName="Default Loadout"
	End Object
	Loadout=DefaultLoadout
	
	Begin Object Class=PlayerHUDSettings Name=PHS
		NumericAmmoDisplay=true
	End Object
	HUDSettings=PHS
	
	ADSDirection=-1
}