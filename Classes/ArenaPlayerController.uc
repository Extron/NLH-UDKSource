/*******************************************************************************
	ArenaPlayerController

	Creation date: 24/06/2012 14:17
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaPlayerController extends UDKPlayerController
	dependson(PlayerData);



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
 * The point in the world to look at.
 */
var vector LookAtPoint;

/** 
 * The current character that the player is using.
 */
var string CurrentCharacter;

/**
 * The time needed to aim down sights.
 */
var float ADSTime;

/**
 * The amount of time that the player has been aiming for.
 */
var float ADSCounter;

var float OldFOV;

/**
 * Allows an FOV offset to be applied to first person weapons and arms.
 */
var float WeaponFOVAddition;

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

/**
 * Indicates that the player is constrained to look at a specific point in space.
 */
var bool ConstrainLookAt;


delegate OnSetPlayerViewpoint(out vector loc, out rotator rot);

function SetCharacter(string inCharacter)
{
	super.SetCharacter(inCharacter);
	
	LoadPlayerData();
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

function SetWeaponFOV()
{
	ArenaPawn(Pawn).SetPlayerFOV(FOVAngle + WeaponFOVAddition);
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
		ArenaPawn(Pawn).SetPlayerFOV(FOVAngle);
	else
		FOV(FOVAngle);
}

function SetLookAt(vector lookAt)
{
	LookAtPoint = lookAt;
	ConstrainLookAt = true;
}

function ClearLookAt()
{
	ConstrainLookAt = false;
}

simulated function GetPlayerViewPoint(out vector loc, out Rotator rot)
{
	local vector socketLocOffset;
	local rotator socketRotOffset;
	
	//if (ArenaPawn(Pawn) != None)
		//ArenaPawn(Pawn).GetCameraSocketLocRot(socketLocOffset, socketRotOffset);

	super.GetPlayerViewPoint(loc, rot);
		
	DefaultLoc = loc + socketLocOffset;	rot = rot + socketRotOffset;
	
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
		rot += ArenaPawn(Pawn).GetRecoil();
	
		if (ArenaPawn(Pawn).ADS || Aiming)
		{
			loc += (ADSOffset >> rot);
		}
	}
	
	if (ConstrainLookAt)
		rot = rotator(LookAtPoint - loc);
		
	if (OnSetPlayerViewpoint != None)
		OnSetPlayerViewpoint(loc, rot);
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
			if (ArenaWeapon(Pawn.Weapon).OnlyAlterWeaponFOV())
				SetFOVWithTime(DefaultFOV + WeaponFOVAddition, ADSTime);
			else	
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

	if (bool(ArenaPlayerInput(PlayerInput).UsePressed) && ArenaPawn(Pawn).NearestInterObject != None)
	{
		if ((ArenaPawn(Pawn).NearestInterObject.MustHold() && ArenaPlayerInput(PlayerInput).UseTimeEdgeDetect(ArenaPawn(Pawn).NearestInterObject.GetTriggerDuration())) || 
			(!ArenaPawn(Pawn).NearestInterObject.MustHold() && ArenaPlayerInput(PlayerInput).UsePressEdgeDetect()))
			ArenaPawn(Pawn).NearestInterObject.InteractWith(Pawn);
	}
	else if (ArenaPlayerInput(PlayerInput).UseReleaseEdgeDetect())
	{
		if (ArenaPawn(Pawn).NearestInterObject != None)
			ArenaPawn(Pawn).NearestInterObject.Release(Pawn);
	}
	ArenaPlayerInput(PlayerInput).UpdateEdgeDetects();
	
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

/*
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
}*/

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

simulated function CreateNewCharacter(string charName, int charClass)
{
	local LoadoutData newLoadout;
	
	newLoadout.CharacterName = charName;
	
	switch (charClass)
	{
		case 0:
			newLoadout.AbilityClass = class'Arena.PC_Electricity';
			break;
		
		case 1:
			newLoadout.AbilityClass = class'Arena.PC_Water';
			break;
			
		case 2:
			newLoadout.AbilityClass = class'Arena.PC_Earth';
			break;
	}
	
	newLoadout.Points += 15;
	SaveData.Cash = 50;
	
	SaveData.Loadouts.AddItem(newLoadout);
}

simulated function LoadoutData GetCharacter(string charName)
{
	local LoadoutData nullData;
	local int i;
	
	for (i = 0; i < SaveData.Loadouts.Length; i++)
	{
		`log("Checking character" @ SaveData.Loadouts[i].CharacterName);
		
		if (SaveData.Loadouts[i].CharacterName == charName)
		{
			`log("Found character");
			return SaveData.Loadouts[i];
		}
	}
	
	return nullData;	
}

simulated function WeaponSchematicData GetWeapon(string weaponName)
{
	local WeaponSchematicData nullData;
	local int i;
	
	for (i = 0; i < SaveData.WeapData.WeaponLibrary.Length; i++)
	{
		if (SaveData.WeapData.WeaponLibrary[i].WeaponName == weaponName)
			return SaveData.WeapData.WeaponLibrary[i];
	}
	
	return nullData;	
}

simulated function SetCharacterLoadout(LoadoutData charLoadout)
{
	local int i;
	
	for (i = 0; i < SaveData.Loadouts.Length; i++)
	{
		if (SaveData.Loadouts[i].CharacterName == charLoadout.CharacterName)
		{
			SaveData.Loadouts[i] = charLoadout;
			break;
		}
	}
}

simulated function AddWeaponSchematic(WeaponSchematicData data)
{
	SaveData.WeapData.WeaponLibrary.AddItem(data);
}

simulated function SetWeaponSchematic(WeaponSchematicData data, string originalName)
{
	local int i;
	
	for (i = 0; i < SaveData.WeapData.WeaponLibrary.Length; i++)
	{
		if (SaveData.WeapData.WeaponLibrary[i].WeaponName == originalName)
		{
			SaveData.WeapData.WeaponLibrary[i] = data;
			break;
		}
	}
}

/**
 * Sets the current loadout used by the player.
 */
simulated function SetCurrentLoadout(string characterName)
{
	Loadout.SetLoadout(GetCharacter(characterName), self);
}

function bool CanAffortWeaponPart(class weaponPart)
{
	if (class<ArenaWeaponBase>(weaponPart) != None)
		return SaveData.Cash >= class<ArenaWeaponBase>(weaponPart).default.Cost;
	else if (class<ArenaWeaponComponent>(weaponPart) != None)
		return SaveData.Cash >= class<ArenaWeaponComponent>(weaponPart).default.Cost;
}

function PurchaseWeaponPart(class weaponPart)
{
	if (class<ArenaWeaponBase>(weaponPart) != None)
	{
		SaveData.WeapData.BoughtBases.AddItem(class<ArenaWeaponBase>(weaponPart));
		SaveData.Cash -= class<ArenaWeaponBase>(weaponPart).default.Cost;
	}
	else if (class<ArenaWeaponComponent>(weaponPart) != None)
	{
		SaveData.WeapData.BoughtComponents.AddItem(class<ArenaWeaponComponent>(weaponPart));
		SaveData.Cash -= class<ArenaWeaponComponent>(weaponPart).default.Cost;
	}
}

function array<string> GetCharacters()
{
	local array<string> charList;
	local int i;
	
	for (i = 0; i < SaveData.Loadouts.Length; i++)
		charList.AddItem(SaveData.Loadouts[i].CharacterName);
	
	return charList;
}

simulated function array<string> GetWeapons()
{
	local array<string> weapList;
	local int i;
	
	for (i = 0; i < SaveData.WeapData.WeaponLibrary.Length; i++)
		weapList.AddItem(SaveData.WeapData.WeaponLibrary[i].WeaponName);
	
	return weapList;
}

function SavePlayerData()
{
	local string filename;
	
	if (PlayerReplicationInfo.PlayerName == "")
			PlayerReplicationInfo.PlayerName = "Nameless";
			
	filename = "../../SaveData/" $ PlayerReplicationInfo.PlayerName $ "_data.bin";
		
	//`log("Attepmting to save player data" @ filename);
	//`log("Player Data:\n" $ SaveData.Serialize());
	
	if (!(class'Engine'.static.BasicSaveObject(SaveData, filename, false, class'Arena.PlayerData'.const.FileVersion)))
		`warn("File save failed.");
}

function LoadPlayerData()
{
	local string filename;
	
	if (!(Role == Role_Authority && WorldInfo.NetMode == NM_DedicatedServer))
	{
		`log("Loading player save data file.");
		if (PlayerReplicationInfo.PlayerName == "")
			PlayerReplicationInfo.PlayerName = "Nameless";
			
		filename = "../../SaveData/" $ PlayerReplicationInfo.PlayerName $ "_data.bin";
		
		//`log("Loading file" @ filename);
		
		SaveData = new class'Arena.PlayerData';
		
		if (!(class'Engine'.static.BasicLoadObject(SaveData, filename, false, class'Arena.PlayerData'.const.FileVersion)))
		{
			`log("No save data detected.  Creating a new file.");
			
			if (!(class'Engine'.static.BasicSaveObject(SaveData, filename, true, class'Arena.PlayerData'.const.FileVersion)))
				`log("File save failed.");
		}
		
		//`log("Save data contents:");
		//`log(SaveData.Serialize());
		
		SaveData.Initialize();
	}
}

simulated function float ComputeNextLevelXP(int level)
{
	return 100 + level * 200 ** level;
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
			ArenaWeaponBase=class'Wp_CheapRifleBase';
			WeaponStock=class'Wp_S_WoodStock';
			WeaponBarrel=class'Wp_B_ShortSimpleBarrel';
			WeaponMuzzle=class'Wp_M_NoMuzzle';
			WeaponOptics=class'Wp_O_VIronSights';
			WeaponSideAttachment=class'Wp_SA_NoSideAttachment';
			WeaponUnderAttachment=class'Wp_UA_Shotgun';
			WeaponName="Cheap Rifle"
		End Object
		PrimaryWeapon=DefaultSchematic
		LoadoutName="Default Loadout"
	End Object
	Loadout=DefaultLoadout
	
	Begin Object Class=PlayerHUDSettings Name=PHS
		NumericAmmoDisplay=true
	End Object
	HUDSettings=PHS
	
	WeaponFOVAddition=-20
	ADSDirection=-1
}