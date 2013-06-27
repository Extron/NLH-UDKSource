/*******************************************************************************
	GFx_WeaponLocker

	Creation date: 27/05/2013 14:26
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_WeaponLocker extends GFx_Menu;


const NativeWidth = 1600;
const NativeHeight = 900;


/**
 * The player that is viewing the locker.
 */
var ArenaPlayerController Viewer;

/**
 * The backdrop to the menu system, to allow a clean background to show while accessing it.
 */
var MenuBackdrop Backdrop;

/**
 * This is the weapon that is currently being displayed.
 */
var ArenaWeapon Weapon;

/**
 * The light environment used to display the weapon.
 */
var DynamicLightEnvironmentComponent MenuLightEnvironment;

/**
 * The up menu light.
 */
var PointLightComponent UpLight;

/**
 * The left menu light.
 */
var PointLightComponent LeftLight;

/**
 * The right menu light.
 */
var PointLightComponent RightLight;

/**
 * The sub menu that lets players switch out weapon parts.
 */
var GFx_WLSubMenu Submenu;

/**
 * The menu container for the weapon stats.
 */
var GFxObject Cursor;

/**
 * The button wrappers for the buttons.
 */
var GFxObject AcceptBW, CancelBW;

/**
 * The tooltip to display when hovering over a weapon part.
 */
var GFx_Tooltip PartTooltip, StatTooltip;

/**
 * The accept and cancel buttons.
 */
var GFxClikWidget AcceptButton, CancelButton, NameLabel, AddMuzzle, AddSide, AddUnder, AddOptics, AddStock;

/**
 * The container for all stat bars that are displayed to the screen.
 */
var GFx_StatBarContainer StatsContainer;

/**
 * The container for all value stats that are displayed to the screen.
 */
var GFx_ValueDisplayContainer ValuesContainer;

/**
 * The energy bar of the weapon.  Will not be visible if the weapon base has no energy amount.
 */
var GFx_StatBar EnergyBar;

/**
 * The drop down list to use for fire modes.
 */
var GFx_ValueDropdown FireModeDDL;

/**
 * The materials of the various weapon parts.  This is used for highlighting selected parts.
 */
var array<MaterialInstanceConstant> WeaponMaterials;

/**
 * To present a clean interface, remove the player's PPC and store it here.
 */
var array<PostProcessChain> PlayerPPCs;

/**
 * The PPC to use while viewing the menu.
 */
var PostProcessChain MenuPPC;

/**
 * The player's view rotation prior to accessing the menu.
 */
var rotator OldViewRotation;

/**
 * Stores the offset of the weapon from the player's location to use when displaying it.
 */
var vector WeaponOffset;

/**
 * The rate that the weapon spins in the UI.
 */
var float SpinRate;

/**
 * The scale of the weapon in the UI.
 */
var float WeaponScale;

/**
 * A hack that allows lighting to show up on the gun model even when the game is paused.  This counter allows the game
 * to be paused a fraction of a second after the menu is activated, allowing the render loop to make a few passes before
 * it pauses, allowing light to fall onto the weapon.
 */
var float Counter;

/**
 * The rate that a highlighted weapon part will pulse.
 */
var float HighlightPulseRate;

/**
 * The index of the selected part.
 */
var int SelectedPart;

/**
 * Indicates that some aspect of the weapon has changed and that the user's weapon needs to be updated.
 */
var bool ChangedWeapon;

var bool ChangedName;

var bool ChangedFireMode;

var int FireModeIndex;

function bool Start(optional bool StartPaused = false)
{	
	local int i;
	local rotator r;
	
	super.Start(StartPaused);
			
    Advance(0);

	StatsContainer = GFx_StatBarContainer(GetVariableObject("_root.details.stats", class'GFx_StatBarContainer'));
	ValuesContainer = GFx_ValueDisplayContainer(GetVariableObject("_root.details.values", class'GFx_ValueDisplayContainer'));
	NameLabel = GfxClikWidget(GetVariableObject("_root.details.name_label", class'GFxClikWidget'));
	Cursor = GetVariableObject("_root.cursor");
	EnergyBar = GFx_StatBar(GetVariableObject("_root.details.energy_bar", class'GFx_StatBar'));
	
	PartTooltip = GFx_Tooltip(GetVariableObject("_root.part_tooltip", class'GFx_Tooltip'));
	StatTooltip = GFx_Tooltip(GetVariableObject("_root.stat_tooltip", class'GFx_Tooltip'));
	
	AcceptBW = GetVariableObject("_root.accept_button");
	CancelBW = GetVariableObject("_root.cancel_button");
	
	AcceptButton = GFxClikWidget(AcceptBW.GetObject("button", class'GFxClikWidget'));
	CancelButton = GFxClikWidget(CancelBW.GetObject("button", class'GFxClikWidget'));

	AcceptButton.AddEventListener('CLIK_click', OnPressAcceptButton);
	CancelButton.AddEventListener('CLIK_click', OnPressCancelButton);
	
	AddMuzzle = GFxClikWidget(GetVariableObject("_root.add_muzzle_button", class'GFxClikWidget'));	
	AddSide = GFxClikWidget(GetVariableObject("_root.add_side_button", class'GFxClikWidget'));	
	AddUnder = GFxClikWidget(GetVariableObject("_root.add_under_button", class'GFxClikWidget'));
	AddOptics = GFxClikWidget(GetVariableObject("_root.add_optics_button", class'GFxClikWidget'));
	AddStock = GFxClikWidget(GetVariableObject("_root.add_stock_button", class'GFxClikWidget'));
	
	AddMuzzle.AddEventListener('CLIK_click', OnPressAddMuzzleButton);
	AddSide.AddEventListener('CLIK_click', OnPressAddSideButton);
	AddUnder.AddEventListener('CLIK_click', OnPressAddUnderButton);
	AddOptics.AddEventListener('CLIK_click', OnPressAddOpticsButton);
	AddStock.AddEventListener('CLIK_click', OnPressAddStockButton);
	
	if (ArenaPlayerController(GetPC()) != None)
	{		
		Viewer = ArenaPlayerController(GetPC());
		OldViewRotation = Viewer.Rotation;
		r.Yaw = OldViewRotation.Yaw;
		
		PlayerPPCs = LocalPlayer(Viewer.Player).PlayerPostProcessChains;
		LocalPlayer(Viewer.Player).RemoveAllPostProcessingChains();
		LocalPlayer(Viewer.Player).InsertPostProcessingChain(MenuPPC, 0, false);
		
		Viewer.SetRotation(r);
		Weapon = CreateWeapon(ArenaWeapon(Viewer.Pawn.Weapon));	
		Backdrop = Weapon.Spawn(class'MenuBackdrop', , , Viewer.Pawn.Location);
		
		Weapon.SetRotation(Viewer.Rotation);
		Weapon.AttachWeapon(MenuLightEnvironment);
		
		SetWeaponParameters();	
		ArenaWeapon(Viewer.Pawn.Weapon).HideWeapon(true);
		
		if (ArenaWeaponBase(Weapon).WeaponComponents[WCStock] == None || Wp_S_NoStock(ArenaWeaponBase(Weapon).WeaponComponents[WCStock]) != None)
			AddStock.SetVisible(true);
		else
			AddStock.SetVisible(false);
			
		if (ArenaWeaponBase(Weapon).WeaponComponents[WCMuzzle] == None || Wp_M_NoMuzzle(ArenaWeaponBase(Weapon).WeaponComponents[WCMuzzle]) != None)
			AddMuzzle.SetVisible(true);
		else
			AddMuzzle.SetVisible(false);
			
		if (ArenaWeaponBase(Weapon).WeaponComponents[WCOptics] == None || Wp_O_NoOptics(ArenaWeaponBase(Weapon).WeaponComponents[WCOptics]) != None &&
			ArenaWeaponBase(Weapon).CanEquipOptics(Wp_Optics(ArenaWeaponBase(Weapon).WeaponComponents[WCOptics])))
			AddOptics.SetVisible(true);
		else
			AddOptics.SetVisible(false);
			
		if (ArenaWeaponBase(Weapon).WeaponComponents[WCUnderAttachment] == None || Wp_UA_NoUnderAttachment(ArenaWeaponBase(Weapon).WeaponComponents[WCUnderAttachment]) != None &&
			Wp_Barrel(ArenaWeaponBase(Weapon).WeaponComponents[WCBarrel]).CanEquipUnderAttachment(Wp_UnderAttachment(ArenaWeaponBase(Weapon).WeaponComponents[WCUnderAttachment])))
			AddUnder.SetVisible(true);
		else
			AddUnder.SetVisible(false);
			
		if (ArenaWeaponBase(Weapon).WeaponComponents[WCSideAttachment] == None || Wp_SA_NoSideAttachment(ArenaWeaponBase(Weapon).WeaponComponents[WCSideAttachment]) != None &&
			Wp_Barrel(ArenaWeaponBase(Weapon).WeaponComponents[WCBarrel]).CanEquipSideAttachment(Wp_SideAttachment(ArenaWeaponBase(Weapon).WeaponComponents[WCSideAttachment])))
			AddSide.SetVisible(true);
		else
			AddSide.SetVisible(false);
			
		Weapon.AttachComponent(UpLight);
		Weapon.AttachComponent(LeftLight);
		Weapon.AttachComponent(RightLight);
		
		if (ArenaWeaponBase(Weapon).EnergyMax <= 0)
			EnergyBar.SetVisible(false);

		EnergyBar.SetStatValue(ArenaWeaponBase(Weapon).GetEnergyUsed(), ArenaWeaponBase(Weapon).EnergyMax);
	}

	NameLabel.SetString("text", "\"" $ Weapon.WeaponName $ "\"");
	NameLabel.AddEventListener('CLIK_click', OnTextInputClick);
	
	for (i = 0; i < 9; i++)
	{		
		if (i > 0)
			StatsContainer.AddStatBar(GetStatName(i), Weapon.Stats.Values[i], Weapon.Stats.GetGGCMax(i));
		else
			StatsContainer.AddStatBar("Weight", ArenaWeaponBase(Weapon).GetWeight(), 25);
	}

	for (i = 0; i < 9; i++)
	{
		if (GetValueName(i) == "Fire Mode" && ArenaWeaponBase(Weapon).AllowedFireModes.Length > 1 && Weapon.FireModes.Length == 1)
			ValuesContainer.AddDropdown(GetValueName(i) $ ":", GetFireModesString(), GetFireModeIndex(ArenaWeaponBase(Weapon).AllowedFireModes, Weapon.FireModes[0]));
		else
			ValuesContainer.AddValue(GetValueName(i) $ ":", GetValue(i));
	}
	
	return true;	
}

function Update(float dt)
{
	local rotator r;
	
	if (Submenu != None && Submenu.bMovieIsOpen)
	{
		Submenu.Update(dt);
		return;
	}
	
	r = Weapon.Rotation;
	
	r.Pitch = 65536.0 / 6.0;
	
	if (SelectedPart == -1)
	{
		r.Yaw += 65536 * dt * SpinRate;
		r.Yaw = r.Yaw % 65536;
	}
	
	Weapon.SetRotation(r);
	Weapon.Tick(dt);
	
	if (SelectedPart > -1)
		WeaponMaterials[SelectedPart].SetScalarParameterValue('EmissionFactor', Sin(Counter * HighlightPulseRate) ** 2);
	
	if (Counter > 2 * dt)
		Viewer.SetPause(true);
	
	Counter += dt;
}

function PostRender()
{
	local ArenaWeaponComponent iter;
	local vector2D mousePos;
	local vector origin, direction;
	local vector traceLoc, traceNorm;
	local bool hit;
	local int index;
	
	if (Submenu != None && Submenu.bMovieIsOpen)
	{
		Submenu.PostRender();
		return;
	}
	
	mousePos.x = Cursor.GetFloat("x") * Viewer.MyHUD.SizeX / NativeWidth;
	mousePos.y = Cursor.GetFloat("y") * Viewer.MyHUD.SizeY / NativeHeight;
	
	Viewer.MyHUD.Canvas.DeProject(mousePos, origin, direction);
	
	ArenaWeaponBase(Weapon).Mesh.SetTraceBlocking(true, true);

	foreach ArenaWeaponBase(Weapon).WeaponComponents(iter, index)
	{
		if (Viewer.TraceComponent(traceLoc, traceNorm, iter.Mesh, origin + direction * 512, origin , , , true))
		{		
			if (SelectedPart > -1)
				WeaponMaterials[SelectedPart].SetScalarParameterValue('EmissionFactor', 0);
		
			SelectedPart = index + 1;
			
			PartTooltip.SetVisible(true);
			StatTooltip.SetVisible(true);
			SetStatTooltip(StatTooltip, iter.StatMod.ValueMods, 1, iter.Weight);
			
			PartTooltip.SetTooltipTitle(iter.ComponentName);
			PartTooltip.SetTooltipBody(iter.ComponentDescription);
			
			hit = true;
			
			break;
		}
	}
	
	if (!hit && Viewer.TraceComponent(traceLoc, traceNorm, ArenaWeaponBase(Weapon).Mesh, origin + direction * 512, origin , , , true))
	{
		if (SelectedPart > -1)
			WeaponMaterials[SelectedPart].SetScalarParameterValue('EmissionFactor', 0);
			
		SelectedPart = 0;
		
		PartTooltip.SetVisible(true);
		StatTooltip.SetVisible(true);
		SetStatTooltip(StatTooltip, Weapon.default.Stats.Values, -1);
		
		PartTooltip.SetTooltipTitle(ArenaWeaponBase(Weapon).BaseName);
		PartTooltip.SetTooltipBody(ArenaWeaponBase(Weapon).BaseDescription);
		
		hit = true;
	}
	
	if (!hit)
	{
		if (SelectedPart > -1)
			WeaponMaterials[SelectedPart].SetScalarParameterValue('EmissionFactor', 0);
			
		SelectedPart = -1;
		
		PartTooltip.SetVisible(false);
		StatTooltip.SetVisible(false);
	}
}

event OnMouseClick()
{
	ShowSubmenu();
}

event OnTextInputClick(GFxClikWidget.EventData ev)
{
	if (!ChangedName)
		NameLabel.SetString("text", Weapon.WeaponName);
	
	ChangedName = true;
	AcceptButton.SetBool("enabled", true);
}

event OnClose()
{
	local int i;
	
	ArenaWeapon(Viewer.Pawn.Weapon).HideWeapon(false);
	Weapon.Destroy();
	Backdrop.Destroy();
	Viewer.SetRotation(OldViewRotation);
	
	LocalPlayer(Viewer.Player).RemoveAllPostProcessingChains();
	
	for (i = 0; i < PlayerPPCs.Length; i++)
		LocalPlayer(Viewer.Player).InsertPostProcessingChain(PlayerPPCs[i], i, false);
}

function OnPressAcceptButton(GFxClikWidget.EventData ev)
{
	local WeaponSchematic schematic;
	local ArenaWeapon newWeapon;
	
	if (ChangedWeapon)
	{
		schematic = new class'Arena.WeaponSchematic';
		
		schematic.WeaponName = Repl(NameLabel.GetString("text"), "\"", "");
		schematic.ArenaWeaponBase = ArenaWeaponBase(Weapon).Class;
		schematic.WeaponStock = Wp_Stock(ArenaWeaponBase(Weapon).WeaponComponents[WCStock]).Class;
		schematic.WeaponBarrel = Wp_Barrel(ArenaWeaponBase(Weapon).WeaponComponents[WCBarrel]).Class;
		schematic.WeaponMuzzle = Wp_Muzzle(ArenaWeaponBase(Weapon).WeaponComponents[WCMuzzle]).Class;
		schematic.WeaponOptics = Wp_Optics(ArenaWeaponBase(Weapon).WeaponComponents[WCOptics]).Class;
		schematic.WeaponSideAttachment = Wp_SideAttachment(ArenaWeaponBase(Weapon).WeaponComponents[WCSideAttachment]).Class;
		schematic.WeaponUnderAttachment = Wp_UnderAttachment(ArenaWeaponBase(Weapon).WeaponComponents[WCUnderAttachment]).Class;
		
		if (ChangedFireMode)
			schematic.WeaponFireModes = GetFireModes();
		
		newWeapon = ArenaPawn(Viewer.Pawn).CreateWeapon(schematic);
		newWeapon.Ammo = Weapon.Ammo;
		newWeapon.Clip = Weapon.Clip;
		
		ArenaPawn(Viewer.Pawn).SwapWeapon(newWeapon);
	}
	else if (ChangedName)
	{
		ArenaWeapon(Viewer.Pawn.Weapon).WeaponName = Repl(NameLabel.GetString("text"), "\"", "");
	}
	
	if (ChangedFireMode && !ChangedWeapon)
		ArenaWeapon(Viewer.Pawn.Weapon).SetFireModes(GetFireModes());
	
    PlayCloseAnimation();
}

function OnPressCancelButton(GFxClikWidget.EventData ev)
{
	PlayCloseAnimation();
}

function ShowSubmenu()
{
	if (SelectedPart > -1 && !(Submenu != None && Submenu.bMovieIsOpen))
	{
		Submenu = new class'Arena.GFx_WLSubmenu';
		Submenu.bEnableGammaCorrection = FALSE;
		Submenu.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(Viewer.Player));
		Submenu.SetTimingMode(TM_Real);
		Submenu.Parent = self;
		Submenu.Viewer = Viewer;
		Submenu.LightEnvironment = MenuLightEnvironment;
		
		if (SelectedPart == 0)
			Submenu.BaseClass = ArenaWeaponBase(Weapon).Class;
		else
			Submenu.ComponentClass = ArenaWeaponBase(Weapon).WeaponComponents[SelectedPart - 1].Class;
		
		PartTooltip.SetVisible(false);
		StatTooltip.SetVisible(false);
		Cursor.SetVisible(false);
		Weapon.HideWeapon(true);
	
		AddMuzzle.SetVisible(false);
		AddSide.SetVisible(false);
		AddUnder.SetVisible(false);
		AddOptics.SetVisible(false);
		AddStock.SetVisible(false);
	
		Submenu.Start();
		Submenu.PlayOpenAnimation();
	}
}

function OnPressAddStockButton(GFxClikWidget.EventData ev)
{
	SelectedPart = 1;
	ShowSubmenu();
}

function OnPressAddMuzzleButton(GFxClikWidget.EventData ev)
{
	SelectedPart = 3;
	ShowSubmenu();
}

function OnPressAddOpticsButton(GFxClikWidget.EventData ev)
{
	SelectedPart = 4;
	ShowSubmenu();
}

function OnPressAddUnderButton(GFxClikWidget.EventData ev)
{
	SelectedPart = 5;
	ShowSubmenu();
}

function OnPressAddSideButton(GFxClikWidget.EventData ev)
{
	SelectedPart = 6;
	ShowSubmenu();
}

function OnDropdownIndexChanged(string ddlName, int index)
{
	ChangedFireMode = true;
	FireModeIndex = index;
	AcceptButton.SetBool("enabled", true);
}

function bool InterceptEscape()
{
	if (Submenu != None && Submenu.bMovieIsOpen)
	{
		Submenu.PlayCloseAnimation();
		
		PartTooltip.SetVisible(true);
		StatTooltip.SetVisible(true);
		Cursor.SetVisible(true);
		Weapon.HideWeapon(false);
		
		if (ArenaWeaponBase(Weapon).WeaponComponents[WCStock] == None || Wp_S_NoStock(ArenaWeaponBase(Weapon).WeaponComponents[WCStock]) != None)
			AddStock.SetVisible(true);
		else
			AddStock.SetVisible(false);
			
		if (ArenaWeaponBase(Weapon).WeaponComponents[WCMuzzle] == None || Wp_M_NoMuzzle(ArenaWeaponBase(Weapon).WeaponComponents[WCMuzzle]) != None)
			AddMuzzle.SetVisible(true);
		else
			AddMuzzle.SetVisible(false);
			
		if (ArenaWeaponBase(Weapon).WeaponComponents[WCOptics] == None || Wp_O_NoOptics(ArenaWeaponBase(Weapon).WeaponComponents[WCOptics]) != None &&
			ArenaWeaponBase(Weapon).CanEquipOptics(Wp_Optics(ArenaWeaponBase(Weapon).WeaponComponents[WCOptics])))
			AddOptics.SetVisible(true);
		else
			AddOptics.SetVisible(false);
			
		if (ArenaWeaponBase(Weapon).WeaponComponents[WCUnderAttachment] == None || Wp_UA_NoUnderAttachment(ArenaWeaponBase(Weapon).WeaponComponents[WCUnderAttachment]) != None &&
			Wp_Barrel(ArenaWeaponBase(Weapon).WeaponComponents[WCBarrel]).CanEquipUnderAttachment(Wp_UnderAttachment(ArenaWeaponBase(Weapon).WeaponComponents[WCUnderAttachment])))
			AddUnder.SetVisible(true);
		else
			AddUnder.SetVisible(false);
			
		if (ArenaWeaponBase(Weapon).WeaponComponents[WCSideAttachment] == None || Wp_SA_NoSideAttachment(ArenaWeaponBase(Weapon).WeaponComponents[WCSideAttachment]) != None &&
			Wp_Barrel(ArenaWeaponBase(Weapon).WeaponComponents[WCBarrel]).CanEquipSideAttachment(Wp_SideAttachment(ArenaWeaponBase(Weapon).WeaponComponents[WCSideAttachment])))
			AddSide.SetVisible(true);
		else
			AddSide.SetVisible(false);
			
		return true;
	}
	
	return false;
}

function ChangeWeaponComponent(class<ArenaWeaponComponent> componentClass)
{
	local ArenaWeaponBase base;
	local ArenaWeaponComponent component;
	local MaterialInstanceConstant mat;
	local name socket;
	local int index;
	local int i;
	
	base = ArenaWeaponBase(Weapon);
	component = base.spawn(componentClass, base, , base.Location, base.Rotation);
	
	if (component.IsA('Wp_Stock'))
	{
		base.Stats.RemoveModifier(base.WeaponComponents[WCStock].StatMod);
		base.WeaponComponents[WCStock].Destroy();
		base.AttachStock(Wp_Stock(component));
		socket = base.Sockets[WCStock];
		index = 1;
	}
	else if (component.IsA('Wp_Barrel'))
	{
		base.Stats.RemoveModifier(base.WeaponComponents[WCBarrel].StatMod);
		base.WeaponComponents[WCBarrel].Destroy();
		base.AttachBarrel(Wp_Barrel(component));
		socket = base.Sockets[WCBarrel];
		index = 2;
	}
	else if (component.IsA('Wp_Muzzle'))
	{
		base.Stats.RemoveModifier(base.WeaponComponents[WCMuzzle].StatMod);
		base.WeaponComponents[WCMuzzle].Destroy();
		base.AttachMuzzle(Wp_Muzzle(component));
		socket = base.Sockets[WCMuzzle];
		index = 3;
	}
	else if (component.IsA('Wp_Optics'))
	{
		base.Stats.RemoveModifier(base.WeaponComponents[WCOptics].StatMod);
		base.WeaponComponents[WCOptics].Destroy();
		base.AttachOptics(Wp_Optics(component));
		socket = base.Sockets[WCOptics];
		index = 4;
	}
	else if (component.IsA('Wp_UnderAttachment'))
	{
		base.Stats.RemoveModifier(base.WeaponComponents[WCUnderAttachment].StatMod);
		base.WeaponComponents[WCUnderAttachment].Destroy();
		base.AttachUnder(Wp_UnderAttachment(component));
		socket = base.Sockets[WCUnderAttachment];
		index = 5;
	}
	else if (component.IsA('Wp_SideAttachment'))
	{
		base.Stats.RemoveModifier(base.WeaponComponents[WCSideAttachment].StatMod);
		base.WeaponComponents[WCSideAttachment].Destroy();
		base.AttachSide(Wp_SideAttachment(component));
		socket = base.Sockets[WCSideAttachment];
		index = 6;
	}
		
	component.Mesh.SetDepthPriorityGroup(SDPG_Foreground);
	component.Mesh.SetOnlyOwnerSee(false);
	component.SetDrawScale(WeaponScale);
	
	component.AttachToBaseSpecial(base, socket, MenuLightEnvironment);
	
	mat = new class'MaterialInstanceConstant';
	mat.SetParent(component.Mesh.GetMaterial(0));
	mat.SetTextureParameterValue('Emission', Texture'ArenaUI.Textures.HighlightTex');
	component.Mesh.SetMaterial(0, mat);
	
	WeaponMaterials[index] = mat;
	
	for (i = 0; i < 9; i++)
	{
		if (i > 0)
			StatsContainer.ChangeStat(i, Weapon.Stats.Values[i], Weapon.Stats.GetGGCMax(i));
		else
			StatsContainer.ChangeStat(i, ArenaWeaponBase(Weapon).GetWeight(), 25);
	}

	for (i = 0; i < 9; i++)
		ValuesContainer.ChangeValue(i, GetValue(i));
	
	AcceptButton.SetBool("enabled", true);
	ChangedWeapon = true;
}

function ChangeWeaponBase(class<ArenaWeaponBase> baseClass)
{
	local ArenaWeaponBase base;
	local ArenaWeaponComponent iter, component;
	local bool prevHadMultipleFM;
	local int i;
	
	base = Weapon.Spawn(baseClass, None, , Weapon.Location, Weapon.Rotation);
	base.WeaponName = Weapon.WeaponName;
	
	foreach ArenaWeaponBase(Weapon).WeaponComponents(iter)
	{
		if (iter.IsA('Wp_Stock'))
		{
			if (iter.CanAttachToBase(base))
			{
				component = base.spawn(Wp_Stock(iter).Class, base, , base.Location, base.Rotation);
				base.AttachStock(Wp_Stock(component));
			}
			else
			{
				component = base.spawn(base.DefaultComponents[WCStock], base, , base.Location, base.Rotation);
				base.AttachStock(Wp_Stock(component));
			}
		}
		else if (iter.IsA('Wp_Barrel'))
		{
			if (iter.CanAttachToBase(base))
			{
				component = base.spawn(Wp_Barrel(iter).Class, base, , base.Location, base.Rotation);
				base.AttachBarrel(Wp_Barrel(component));
			}
			else
			{
				component = base.spawn(base.DefaultComponents[WCBarrel], base, , base.Location, base.Rotation);
				base.AttachBarrel(Wp_Barrel(component));
			}
		}
		else if (iter.IsA('Wp_Muzzle'))
		{
			if (iter.CanAttachToBase(base))
			{
				component = base.spawn(Wp_Muzzle(iter).Class, base, , base.Location, base.Rotation);
				base.AttachMuzzle(Wp_Muzzle(component));
			}
			else
			{
				component = base.spawn(base.DefaultComponents[WCMuzzle], base, , base.Location, base.Rotation);
				base.AttachMuzzle(Wp_Muzzle(component));
			}
		}
		else if (iter.IsA('Wp_Optics'))
		{
			if (iter.CanAttachToBase(base))
			{
				component = base.spawn(Wp_Optics(iter).Class, base, , base.Location, base.Rotation);
				base.AttachOptics(Wp_Optics(component));
			}
			else
			{
				component = base.spawn(base.DefaultComponents[WCOptics], base, , base.Location, base.Rotation);
				base.AttachOptics(Wp_Optics(component));
			}
		}
		else if (iter.IsA('Wp_UnderAttachment'))
		{
			if (iter.CanAttachToBase(base))
			{
				component = base.spawn(Wp_UnderAttachment(iter).Class, base, , base.Location, base.Rotation);
				base.AttachUnder(Wp_UnderAttachment(component));
			}
			else
			{
				component = base.spawn(base.DefaultComponents[WCUnderAttachment], base, , base.Location, base.Rotation);
				base.AttachUnder(Wp_UnderAttachment(component));
			}
		}
		else if (iter.IsA('Wp_SideAttachment'))
		{
			if (iter.CanAttachToBase(base))
			{
				component = base.spawn(Wp_SideAttachment(iter).Class, base, , base.Location, base.Rotation);
				base.AttachSide(Wp_SideAttachment(component));
			}
			else
			{
				component = base.spawn(base.DefaultComponents[WCSideAttachment], base, , base.Location, base.Rotation);
				base.AttachSide(Wp_SideAttachment(component));
			}
		}
	}
	
	prevHadMultipleFM = ArenaWeaponBase(Weapon).AllowedFireModes.Length > 1;
	
	Weapon.DetachComponent(UpLight);
	Weapon.DetachComponent(LeftLight);
	Weapon.DetachComponent(RightLight);
	
	Weapon.Destroy();
	WeaponMaterials.Length = 0;
	Weapon = base;

	Weapon.AttachWeapon(MenuLightEnvironment);
	SetWeaponParameters();
	Weapon.EnsureWeaponOverlayComponentLast();

	Weapon.AttachComponent(UpLight);
	Weapon.AttachComponent(LeftLight);
	Weapon.AttachComponent(RightLight);
	
	if (ArenaWeaponBase(Weapon).EnergyMax <= 0)
		EnergyBar.SetVisible(false);

	EnergyBar.SetStatValue(ArenaWeaponBase(Weapon).GetEnergyUsed(), ArenaWeaponBase(Weapon).EnergyMax);
	
	Viewer.SetPause(false);
	Counter = 0;
	
	for (i = 0; i < 9; i++)
	{
		if (i > 0)
			StatsContainer.ChangeStat(i, Weapon.Stats.Values[i], Weapon.Stats.GetGGCMax(i));
		else
			StatsContainer.ChangeStat(i, ArenaWeaponBase(Weapon).GetWeight(), 25);
	}

	if (prevHadMultipleFM && base.AllowedFireModes.Length <= 1)
	{
		ValuesContainer.RemoveDropdown("Fire Mode:");
		ValuesContainer.InsertValue("Fire Mode:", GetValue(2), 3);
	}
	else if (!prevHadMultipleFM && base.AllowedFireModes.Length > 1)
	{
		ValuesContainer.RemoveValue("Fire Mode:");
		ValuesContainer.InsertDropdown("Fire Mode:", GetFireModesString(), 0, 3);
	}
	else if (prevHadMultipleFM && base.AllowedFireModes.Length > 1)
	{
		ValuesContainer.ChangeDropdown(2, GetFireModesString(), 0);
	}
	
	for (i = 0; i < 9; i++)
	{
		if (prevHadMultipleFM && base.AllowedFireModes.Length <= 1 && i > 0)
			ValuesContainer.ChangeValue(i, GetValue(i - 1));
		else
			ValuesContainer.ChangeValue(i, GetValue(i - 1));
	}
	
	AcceptButton.SetBool("enabled", true);
	ChangedWeapon = true;
}

function ArenaWeapon CreateWeapon(ArenaWeapon currentWeapon)
{
	local ArenaWeaponBase ArenaWeaponBase;
	local Wp_Stock stock;
	local Wp_Barrel barrel;
	local Wp_Muzzle muzzle;
	local Wp_Optics optics;
	local Wp_SideAttachment side;
	local Wp_UnderAttachment under;

	ArenaWeaponBase = currentWeapon.Spawn(ArenaWeaponBase(currentWeapon).Class, None, , Viewer.Pawn.Location + (WeaponOffset >> Viewer.Rotation), Viewer.Rotation);
	ArenaWeaponBase.WeaponName = currentWeapon.WeaponName;

	stock = currentWeapon.spawn(Wp_Stock(ArenaWeaponBase(currentWeapon).WeaponComponents[WCStock]).Class, ArenaWeaponBase, , ArenaWeaponBase.Location, ArenaWeaponBase.Rotation);
	barrel = currentWeapon.spawn(Wp_Barrel(ArenaWeaponBase(currentWeapon).WeaponComponents[WCBarrel]).Class, ArenaWeaponBase, , ArenaWeaponBase.Location, ArenaWeaponBase.Rotation);
	muzzle = currentWeapon.spawn(Wp_Muzzle(ArenaWeaponBase(currentWeapon).WeaponComponents[WCMuzzle]).Class, ArenaWeaponBase, , ArenaWeaponBase.Location, ArenaWeaponBase.Rotation);
	optics = currentWeapon.spawn(Wp_Optics(ArenaWeaponBase(currentWeapon).WeaponComponents[WCOptics]).Class, ArenaWeaponBase, , ArenaWeaponBase.Location, ArenaWeaponBase.Rotation);
	side = currentWeapon.spawn(Wp_SideAttachment(ArenaWeaponBase(currentWeapon).WeaponComponents[WCSideAttachment]).Class, ArenaWeaponBase, , ArenaWeaponBase.Location, ArenaWeaponBase.Rotation);
	under = currentWeapon.spawn(Wp_UnderAttachment(ArenaWeaponBase(currentWeapon).WeaponComponents[WCUnderAttachment]).Class, ArenaWeaponBase, , ArenaWeaponBase.Location, ArenaWeaponBase.Rotation);
	
	ArenaWeaponBase.AttachStock(stock);
	ArenaWeaponBase.AttachBarrel(barrel);
	ArenaWeaponBase.AttachMuzzle(muzzle);
	ArenaWeaponBase.AttachOptics(optics);
	ArenaWeaponBase.AttachSide(side);
	ArenaWeaponBase.AttachUnder(under);
	
	ArenaWeaponBase.SetFireModes(currentWeapon.FireModes);
	
	return ArenaWeaponBase;
}

function SetWeaponParameters()
{
	local ArenaWeaponComponent iter;
	local MaterialInstanceConstant mat;
	
	ArenaWeaponBase(Weapon).Mesh.SetDepthPriorityGroup(SDPG_Foreground);
	ArenaWeaponBase(Weapon).Mesh.SetOnlyOwnerSee(false);	
	ArenaWeaponBase(Weapon).SetDrawScale(WeaponScale);
	
	foreach ArenaWeaponBase(Weapon).WeaponComponents(iter)
	{
		iter.Mesh.SetDepthPriorityGroup(SDPG_Foreground);
		iter.Mesh.SetOnlyOwnerSee(false);
		iter.SetDrawScale(WeaponScale);
	}
	
	mat = new class'MaterialInstanceConstant';
	mat.SetParent(ArenaWeaponBase(Weapon).Mesh.GetMaterial(0));
	mat.SetTextureParameterValue('Emission', Texture'ArenaUI.Textures.HighlightTex');
	ArenaWeaponBase(Weapon).Mesh.SetMaterial(0, mat);
	
	WeaponMaterials.AddItem(mat);
	
	foreach ArenaWeaponBase(Weapon).WeaponComponents(iter)
	{
		mat = new class'MaterialInstanceConstant';
		mat.SetParent(iter.Mesh.GetMaterial(0));
		mat.SetTextureParameterValue('Emission', Texture'ArenaUI.Textures.HighlightTex');
		iter.Mesh.SetMaterial(0, mat);	
		WeaponMaterials.AddItem(mat);
	}
}

function string GetStatName(int stat)
{
	switch (stat)
	{
	case 0:
		return "Weight";
		
	case 1:
		return "Accuracy";
		
	case 2:
		return "Stability";
		
	case 3:
		return "Mobility";
		
	case 4:
		return "Recoil";
		
	case 5:
		return "Zoom";
		
	case 6:
		return "Rate of Fire";
		
	case 7:
		return "Rate of Cycle";
		
	case 8:
		return "Damage";
		
	default:
		return "";
	}
}

function string GetValueName(int value)
{
	switch (value)
	{
	case 0:
		return "Type";
		
	case 1:
		return "Size";
		
	case 2:
		return "Fire Mode";
		
	case 3:
		return "Magnification";
		
	case 4:
		return "Total Damage";
		
	case 5:
		return "Reload Speed";
		
	case 6:
		return "Equip Speed";
		
	case 7:
		return "Clip Size";
		
	case 8:
		return "Bloom";
		
	default:
		return "";
	}
}

function int GetFireModeIndex(array<FireMode> AllowedFireModes, FireMode currFireMode)
{
	local int index;
	
	for (index = 0; index < AllowedFireModes.Length; index++)
	{
		if (AllowedFireModes[index] == currFireMode)
			return index;
	}
	
	return 0;
}

function array<string> GetFireModesString()
{
	local array<string> modes;
	local int i;

	for (i = 0; i < ArenaWeaponBase(Weapon).AllowedFireModes.Length; i++)
	{
		switch (ArenaWeaponBase(Weapon).AllowedFireModes[i])
		{
		case FMBoltAction:
			modes.AddItem("Bolt Action");
			break;
			
		case FMSemiAuto:
			modes.AddItem("Semi-automatic");
			break;
			
		case FMBurst:
			modes.AddItem(Weapon.BurstCount $ "-Round Burst");
			break;
			
		case FMFullAuto:
			modes.AddItem("Full-automatic");
			break;
			
		case FMBeam:
			modes.AddItem("Beam");
			break;
		}
	}

	
	return modes;
}

function array<FireMode> GetFireModes()
{
	local array<FireMode> modes;

	modes.AddItem(ArenaWeaponBase(Weapon).AllowedFireModes[FireModeIndex]);
	
	return modes;
}

function string GetValue(int value)
{
	switch (value)
	{
	case 0:
		switch (Weapon.Type)
		{
		case WTRifle:
			return "Rifle";
			
		case WTShotgun:
			return "Shotgun";
			
		case WTRocketLauncher:
			return "Rocket Launcher";
			
		case WTGrenadeLauncher:
			return "Grenade Launcher";
			
		case WTHardLightRifle:
			return "Photon Emitter";
			
		case WTBeamRifle:
			return "Particle Beam";
			
		case WTPlasmaRifle:
			return "Plasma Torch";
			
		case WTRailGun:
			return "Railgun";
		}
		break;	
		
		
	case 1:
		switch (Weapon.Size)
		{
		case WSHand:
			return "Handgun";
			
		case WSSmall:
			return "Small";
			
		case WSRegular:
			return "Regular";
			
		case WSLarge:
			return "Large";
			
		case WSHeavy:
			return "Heavy";
		}
		break;
		
	case 2:
		switch (Weapon.FireModes[Weapon.Mode])
		{
		case FMBoltAction:
			return "Bolt Action";
			
		case FMSemiAuto:
			return "Semi-automatic";
			
		case FMBurst:
			return Weapon.BurstCount $ "-Round Burst";
			
		case FMFullAuto:
			return "Full-automatic";
			
		case FMBeam:
			return "Beam";
		}
		break;
		
	case 3:
		return TruncTo(string(ArenaWeaponBase(Weapon).GetZoomLevel()), 3) $ "x";
		
	case 4:
		return TruncTo(string(Weapon.BaseDamage * Weapon.Stats.GetDamageModifier()), 3);
		
	case 5:
		return TruncTo(string(Weapon.GetAvgReloadSpeed()), 3) @ "s";
		
	case 6:
		return TruncTo(string(Weapon.GetAvgEquipSpeed()), 3) @ "s";
		
	case 7:
		return Weapon.MaxClip @ "rounds";
		
	case 8:
		return TruncTo(string(Weapon.Stats.GetBloomCost()), 3);
	}
}

function SetStatTooltip(GFx_Tooltip tooltip, array<float> valueList, float ignoreValue, optional float weight = -1)
{
	local string statString;
	local int i;
	
	statString = "";
	tooltip.SetTooltipTitle("Stat Modifiers");
	
	if (weight >= 0)
		statString = statString @ "Weight:" @ weight $ "\n";
		
	for (i = 0; i < 9; i++)
	{
		if (valueList[i] != ignoreValue)
			statString = statString @ GetStatName(i) $ ":" @ valueList[i] $ "\n";
	}
	
	tooltip.SetTooltipBody(statString);
}

function string TruncTo(string Str, int Places)
{
	local int Whole;
	local string Dec;

	Whole = int(Str);
	Dec = Left(Split(Str, ".", true), Places);

	return string(Whole)$"."$Dec;
}

defaultproperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=LE
	End Object
	MenuLightEnvironment=LE	
	
	Begin Object Class=PointLightComponent Name=UL
		Brightness=3
		LightColor=(R=225,G=225,B=255,A=255)
		Translation=(Z=25)
		LightEnvironment=LE
	End Object
	
	UpLight=UL
	
	Begin Object Class=PointLightComponent Name=LL
		Brightness=3
		LightColor=(R=255,G=255,B=225,A=255)
		Translation=(X=-25)
		LightEnvironment=LE
	End Object
	
	LeftLight=LL
	
	Begin Object Class=PointLightComponent Name=RL
		Brightness=3
		LightColor=(R=255,G=225,B=255,A=255)
		Translation=(X=25)
		LightEnvironment=LE
	End Object
	
	RightLight=RL
	
	MovieInfo=SwfMovie'ArenaUI.WeaponLockerUI'
	
	MenuPPC=PostProcessChain'ArenaMaterials.PostProcess.MenuPPC'
	
	WeaponOffset=(X=64, Y=30, Z=56)
	WeaponScale=0.5
	SpinRate=0.05
	HighlightPulseRate=2.5
	SelectedPart=-1
	InGame=true
	bCaptureInput=true
	bCaptureMouseInput=true
	
	FocusIgnoreKeys[0]=Escape
	//bPauseGameWhileActive=true
}