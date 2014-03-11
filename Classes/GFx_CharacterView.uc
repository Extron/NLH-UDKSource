/*******************************************************************************
	GFx_CharacterView

	Creation date: 20/09/2013 10:19
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_CharacterView extends GFx_Menu
	dependson(PlayerData);

	
/**
 * The Dek cube to use to help display the menu.
 */
var SkeletalMeshComponent Cube;

/**
 * The local pawn that is viewing the menu.
 */
var AP_Specter Pawn;

var LoadoutData Character;

var string SelectedWeapon;

var float LookUpCounter;

var float LookUpTime;

/**
 * Indicates that when transitioning to the weapon editor menu, we have created a new weapon.
 */
var bool NewWeapon;

var int LookDirection;

/**
 * The delegate to call when the menu closes.
 */
delegate OnClose();


function bool Start(optional bool StartPaused = false)
{
	local SkeletalMeshActor iter;

	super.Start(StartPaused);
			
    Advance(0);
	
	if (AP_Specter(GetPC().Pawn) != None)
	{
		Pawn = AP_Specter(GetPC().Pawn);
		Pawn.SetMenu(self);
		ArenaPlayerController(Pawn.Controller).OnSetPlayerViewpoint = LookUp;
	}
	
	foreach Pawn.AllActors(class'SkeletalMeshActor', iter)
	{
		if (iter.Tag == 'DekCube')
		{
			Cube = iter.SkeletalMeshComponent;
			break;
		}
	}
			
	BuildCharacterProfile();
	
	return true;
}

function Update(float dt)
{
	if (LookUpCounter <= LookUpTime)
		LookUpCounter += dt * LookDirection;
}

function LookUp(out vector loc, out rotator rot)
{
	rot.Pitch = 16384 * FMin(LookUpCounter / LookUpTime, 1.0);
}

function BuildCharacterProfile()
{
	local GFxObject classInfo, stats;
	local GFxObject equippedAbilities;
	local GFxObject ability;
	local GFxObject stat;
	local string charType;
	local array<string> statNames;
	local int i;
	
	statNames[0] = "Weight"; statNames[1] = "Mobility";  statNames[2] = "Accuracy";  statNames[3] = "Stability";  statNames[4] = "Movement";  statNames[5] = "Health";  statNames[6] = "Energy"; 
	
	classInfo = CreateObject("Object");
	equippedAbilities = CreateArray();
	
	`log("Character Loadout" @ Character.CharacterName);
	
	if (Character.AbilityClass == class'Arena.PC_Electricity')
	{
		charType = "Tempest";
		classInfo.SetString("className", "Electricity");
	}
	else if (Character.AbilityClass == class'Arena.PC_Water')
	{
		charType = "Lamentia";
		classInfo.SetString("className", "water");
	}
	else if (Character.AbilityClass == class'Arena.PC_Earth')
	{
		charType = "Solus";
		classInfo.SetString("className", "earth");
	}
		 
	for (i = 0; i < Character.EquippedAbilities.Length; i++)
	{
		ability = CreateObject("Object");
		
		ability.SetString("ability", Character.EquippedAbilities[i].default.AbilityName);
		ability.SetFloat("cost", Character.EquippedAbilities[i].default.EnergyCost);
		ability.SetFloat("cooldown", Character.EquippedAbilities[i].default.CoolDown);
		ability.SetString("description", Character.EquippedAbilities[i].default.AbilityDescription);
		ability.SetString("imgSrc", "img://" $ Character.EquippedAbilities[i].default.AbilityIcon);
		
		equippedAbilities.SetElementObject(i, ability);
	}
	
	classInfo.SetObject("equippedAbilities", equippedAbilities);
	
	SetClassInfo(classInfo);
	SetCharacter(Character.CharacterName, charType, Character.Level);
	SetXP(Character.XP, ArenaPlayerController(Pawn.Controller).ComputeNextLevelXP(Character.Level));
	
	BuildPrimanyWeaponInfo();
	
	stats = CreateArray();
	
	for (i = 0; i < 7; i++)
	{
		stat = CreateObject("Object");
		
		stat.SetString("statName", statNames[i]);
		stat.SetFloat("statValue", class'Arena.GlobalGameConstants'.static.GetStatDefault(statNames[i]) * Character.AbilityClass.default.Mod.ValueMods[class'Arena.PlayerStats'.static.GetStatEnum(statNames[i])]);
		stat.SetFloat("statDefault", class'Arena.GlobalGameConstants'.static.GetStatDefault(statNames[i]));
		
		stats.SetElementObject(i, stat);
	}
	
	SetStats(stats);
}

function BuildClassInfo()
{
	local GFxObject classInfo;
	local GFxObject equippedAbilities;
	local GFxObject ability;
	local int i;
	
	classInfo = CreateObject("Object");
	equippedAbilities = CreateArray();
	
	if (Character.AbilityClass == class'Arena.PC_Electricity')
		classInfo.SetString("className", "Electricity");
	else if (Character.AbilityClass == class'Arena.PC_Water')
		classInfo.SetString("className", "water");
	else if (Character.AbilityClass == class'Arena.PC_Earth')
		classInfo.SetString("className", "earth");
		 
	for (i = 0; i < Character.EquippedAbilities.Length; i++)
	{
		ability = CreateObject("Object");
		
		ability.SetString("ability", Character.EquippedAbilities[i].default.AbilityName);
		ability.SetFloat("cost", Character.EquippedAbilities[i].default.EnergyCost);
		ability.SetFloat("cooldown", Character.EquippedAbilities[i].default.CoolDown);
		ability.SetString("description", Character.EquippedAbilities[i].default.AbilityDescription);
		ability.SetString("imgSrc", "img://" $ Character.EquippedAbilities[i].default.AbilityIcon);
		
		equippedAbilities.SetElementObject(i, ability);
	}
	
	classInfo.SetObject("equippedAbilities", equippedAbilities);
	
	SetClassInfo(classInfo);
}

function BuildPrimanyWeaponInfo()
{
	local WeaponSchematicData schematic, nullData;
	local GFxObject weapSchem;
	local GFxObject baseObj;
	local GFxObject componentArray;
	local GFxObject component;
	local int i, index;
	
	schematic = ArenaPlayerController(Pawn.Controller).GetWeapon(Character.PrimaryWeaponName);
	
	if (schematic == nullData)
		return;
		
	weapSchem = CreateObject("Object");
	
	weapSchem.SetString("weapName", schematic.WeaponName);
	
	baseObj = CreateObject("Object");
	
	baseObj.SetString("baseName", schematic.BaseClass.default.BaseName);
	baseObj.SetString("icon", "img://" $ schematic.BaseClass.default.BaseIcon);
	
	componentArray = CreateArray();
	
	index = 0;
	
	for (i = 0; i < schematic.Components.Length; i++)
	{
		if (DisplayComponentType(schematic.Components[i]))
		{
			component = CreateObject("Object");
			
			component.SetString("compType", GetComponentType(schematic.Components[i]));
			component.SetString("compName", schematic.Components[i].default.ComponentName);
			component.SetString("icon", "img://" $ schematic.Components[i].default.ComponentIcon);
			
			componentArray.SetElementObject(index, component);
			index++;
		}
	}
	
	weapSchem.SetObject("baseComp", baseObj);
	weapSchem.SetObject("components", componentArray);
	
	SetPrimaryWeapon(weapSchem);
}

function ButtonClicked(string label)
{
	if (label == "Save")
	{
		ArenaPlayerController(Pawn.Controller).SetCharacterLoadout(Character);
		ArenaPlayerController(Pawn.Controller).SavePlayerData();
		OnClose = GotoMainMenu;
		LookDirection = -1;
		LookUpCounter = LookUpTime;
	}
	else if (label == "Equip Ability")
	{
		OnClose = GotoAbilitiesMenu;
		CloseMenu();
	}
	else if (label == "Edit Weapon")
	{
		OnClose = GotoWeaponEditorMenu;
		CloseMenu();
	}
}

function CancelButtonClicked()
{
	OnClose = GotoMainMenu;
	LookDirection = -1;
	LookUpCounter = LookUpTime;
}

function CreateNewWeaponSchematic()
{
	local WeaponSchematicData newWeap;
	
	newWeap.BaseClass = class'Arena.Wp_CheapRifleBase';
	
	newWeap.Components[WCStock] = class'Arena.Wp_S_CheapStock';
	newWeap.Components[WCBarrel] = class'Arena.Wp_B_BasicRifleBarrel';
	newWeap.Components[WCMuzzle] = class'Arena.Wp_M_NoMuzzle';
	newWeap.Components[WCOptics] = class'Arena.Wp_O_CheapIronSights';
	newWeap.Components[WCUnderAttachment] = class'Arena.Wp_UA_NoUnderAttachment';
	newWeap.Components[WCSideAttachment] = class'Arena.Wp_SA_NoSideAttachment';
	newWeap.WeaponName = "New Weapon" @ ArenaPlayerController(Pawn.Controller).SaveData.WeapData.WeaponLibrary.Length;
	newWeap.FireModes[0] = FMFullAuto;
	
	ArenaPlayerController(Pawn.Controller).AddWeaponSchematic(newWeap);
	SelectedWeapon = newWeap.WeaponName;
	OnClose = GotoWeaponEditorMenu;
	NewWeapon = true;
	CloseMenu();
}

function EditWeaponSchematic(string weapon)
{
	NewWeapon = false;
	SelectedWeapon = weapon;
	OnClose = GotoWeaponEditorMenu;
	CloseMenu();
}

function SelectWeaponSchematic(string weapon)
{
	Character.PrimaryWeaponName = weapon;
	BuildPrimanyWeaponInfo();
	DispatchPopupClose();
}

function RemoveAbility(int abilityIndex)
{
	Character.EquippedAbilities.Remove(abilityIndex, 1);
	
	BuildClassInfo();
}

function CloseMenu()
{
	ActionScriptVoid("_root.CloseMenu");
}

function PlayOpenAnimation()
{
	ActionScriptVoid("_root.OpenMenu");
}

function CloseAnimCompleted()
{
	OnClose();
}

function GotoMainMenu()
{
	local GFx_MainMenu menu;
	
	`log("Going to main menu");
	
	menu = new class'Arena.GFx_MainMenu';
	menu.bEnableGammaCorrection = FALSE;
	menu.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerController(Pawn.Controller).Player));
	menu.SetTimingMode(TM_Real);

	Cube.Owner.SetRotation(rot(0, -16384, 0));
	Cube.Owner.SetPhysics(PHYS_Rotating);
	
	menu.Start();
	menu.PlayOpenAnimation();
	
	Pawn.SetMenu(menu);
	
	ArenaPlayerController(Pawn.Controller).OnSetPlayerViewpoint = None;
	
	Close();
}

function GotoAbilitiesMenu()
{
	local GFx_AbilitiesMenu menu;
	
	menu = new class'Arena.GFx_AbilitiesMenu';
	menu.bEnableGammaCorrection = FALSE;
	menu.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerController(Pawn.Controller).Player));
	menu.SetTimingMode(TM_Real);
	menu.AbilityClass = Character.AbilityClass;
	menu.Parent = self;
	menu.Character = Character;
	
	ArenaPlayerController(Pawn.Controller).OnSetPlayerViewpoint = None;
	
	menu.Start();
	menu.PlayOpenAnimation();
	
	Pawn.SetMenu(menu);
}


function GotoWeaponEditorMenu()
{
	local GFx_WeaponEditor menu;

	menu = new class'Arena.GFx_WeaponEditor';
	menu.bEnableGammaCorrection = FALSE;
	menu.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerController(Pawn.Controller).Player));
	menu.SetTimingMode(TM_Real);
	menu.WeaponData = ArenaPlayerController(Pawn.Controller).GetWeapon(SelectedWeapon);
	menu.Parent = self;
	//menu.Character = Character;
	
	if (NewWeapon)
		menu.ChangedWeapon = true;
		
	ArenaPlayerController(Pawn.Controller).OnSetPlayerViewpoint = None;
	
	menu.Start();
	menu.PlayOpenAnimation();
}

function SetCharacter(string charName, string charType, int charLevel)
{
	ActionScriptVoid("_root.SetCharacter");
}

function SetClassInfo(GFxObject classInfo)
{
	ActionScriptVoid("_root.SetClassInfo");
}

function SetPrimaryWeapon(GFxObject weaponInfo)
{
	ActionScriptVoid("_root.SetPrimaryWeapon");
}

function SetStats(GFxObject stats)
{
	ActionScriptVoid("_root.SetStats");
}

function SetXP(float xp, float nextLevel)
{
	ActionScriptVoid("_root.SetXP");
}

function DispatchPopupClose()
{
	ActionScriptVoid("_root.DispatchPopupClose");
}

function array<string> GetWeaponLibrary()
{
	return ArenaPlayerController(Pawn.Controller).GetWeapons();
}

function string GetComponentType(class<ArenaWeaponComponent> component)
{
	if (class<Wp_Stock>(component) != None)
		return "Stock:";
	else if (class<Wp_Barrel>(component) != None)
		return "Barrel:";
	else if (class<Wp_Muzzle>(component) != None)
		return "Muzzle:";
	else if (class<Wp_Optics>(component) != None)
		return "Optics:";
	else if (class<Wp_UnderAttachment>(component) != None)
		return "Under Attachment:";
	else if (class<Wp_SideAttachment>(component) != None)
		return "Side Attachment:";
	else
		return "";
}

function bool DisplayComponentType(class<ArenaWeaponComponent> component)
{
	if (class<Wp_S_NoStock>(component) != None)
		return false;
	else if (class<Wp_B_NoBarrel>(component) != None)
		return false;
	else if (class<Wp_M_NoMuzzle>(component) != None)
		return false;
	else if (class<Wp_O_NoOptics>(component) != None)
		return false;
	else if (class<Wp_UA_NoUnderAttachment>(component) != None)
		return false;
	else if (class<Wp_SA_NoSideAttachment>(component) != None)
		return false;
	else
		return true;
}

defaultproperties
{
	MovieInfo=SwfMovie'ArenaUI.CharacterView'
	SelectedWeapon="Default Weapon"
	LookDirection=1
	LookUpTime=0.33
	bCaptureInput=true
}