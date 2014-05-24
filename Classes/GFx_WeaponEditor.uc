/*******************************************************************************
	GFx_WeaponEditor

	Creation date: 30/09/2013 10:47
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_WeaponEditor extends GFx_Menu;

const NativeWidth = 1600;
const NativeHeight = 900;

/**
 * The pawn that represents the menu viewer.
 */
var AP_Specter Pawn;

/**
 * The parent menu that we came from to get here.
 */
var GFx_Menu Parent;

/**
 * The weapon data we are editing.
 */
var WeaponSchematicData WeaponData;

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
 * The menu container for the weapon stats.
 */
var GFxObject Cursor;

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
 * Stores the offset of the weapon from the player's location to use when displaying it.
 */
var vector WeaponOffset;

var rotator Rotation;

/**
 * The last recorded position of the mouse.
 */
var vector2D MousePosition;

/**
 * Since we use the weapon's name to index into the library, store the old name here for when we try and save the edited schematic, which may have a different name.
 */
var string OriginalName;

/**
 * The rate that the weapon spins in the UI.
 */
var float SpinRate;

/**
 * The scale of the weapon in the UI.
 */
var float WeaponScale;

/**
 * The rate that a highlighted weapon part will pulse.
 */
var float HighlightPulseRate;

var float Counter;

/**
 * Indicates that some aspect of the weapon has changed and that the user's weapon needs to be updated.
 */
var bool ChangedWeapon;

var bool ChangedName;

/**
 * Indicates that the left mouse is being dragged, which should rotate the weapon.
 */
var bool DraggingMouse;

/**
 * Indicates that the right mouse is being dragged, which should rotate the weapon.
 */
var bool DraggingRightMouse;

/**
 * The index of the selected part.
 */
var int SelectedPart;


//var bool ChangedFireMode;

var int FireModeIndex;



delegate OnClose();

function bool Start(optional bool StartPaused = false)
{	
	local int i;
	
	super.Start(StartPaused);
			
    Advance(0);

	OriginalName = WeaponData.WeaponName;
	
	StatsContainer = GFx_StatBarContainer(GetVariableObject("_root.details.stats", class'GFx_StatBarContainer'));
	ValuesContainer = GFx_ValueDisplayContainer(GetVariableObject("_root.details.values", class'GFx_ValueDisplayContainer'));
	NameLabel = GfxClikWidget(GetVariableObject("_root.details.name_label", class'GFxClikWidget'));
	Cursor = GetVariableObject("_root.cursor");
	EnergyBar = GFx_StatBar(GetVariableObject("_root.details.energy_bar", class'GFx_StatBar'));
	
	PartTooltip = GFx_Tooltip(GetVariableObject("_root.part_tooltip", class'GFx_Tooltip'));
	StatTooltip = GFx_Tooltip(GetVariableObject("_root.stat_tooltip", class'GFx_Tooltip'));
	
	AcceptButton = GFxClikWidget(GetVariableObject("_root.accept_button", class'GFxClikWidget'));
	CancelButton = GFxClikWidget(GetVariableObject("_root.cancel_button", class'GFxClikWidget'));
	
	AcceptButton.AddEventListener('CLIK_click', OnPressAcceptButton);
	CancelButton.AddEventListener('CLIK_click', OnPressCancelButton);
	
	if (ChangedWeapon)
		AcceptButton.SetBool("enabled", true);
		
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
	
	if (AP_Specter(GetPC().Pawn) != None)
	{
		Pawn = AP_Specter(GetPC().Pawn);
		Pawn.SetMenu(self);
		ArenaPlayerController(Pawn.Controller).OnSetPlayerViewpoint = LookUp;
	}
	
	Weapon = CreateWeapon();
	
	Weapon.SetRotation(Pawn.Controller.Rotation);
	Weapon.AttachWeapon(MenuLightEnvironment);
	
	SetWeaponParameters();
	
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
	local vector playerViewLoc;
	local rotator playerViewRot;
	
	Pawn.Controller.GetPlayerViewPoint(playerViewLoc, playerViewRot);
	
	Weapon.SetRotation(RTransform(Rotation, playerViewRot));
	Weapon.SetWeaponScale(WeaponScale);
	
	if (SelectedPart > -1)
		WeaponMaterials[SelectedPart].SetScalarParameterValue('EmissionFactor', Sin(Counter * HighlightPulseRate) ** 2);
		
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
	
	mousePos.x = Cursor.GetFloat("x") * ArenaPlayerController(Pawn.Controller).MyHUD.SizeX / NativeWidth;
	mousePos.y = Cursor.GetFloat("y") * ArenaPlayerController(Pawn.Controller).MyHUD.SizeY / NativeHeight;
	
	ArenaPlayerController(Pawn.Controller).MyHUD.Canvas.DeProject(mousePos, origin, direction);
	
	ArenaWeaponBase(Weapon).Mesh.SetTraceBlocking(true, true);

	foreach ArenaWeaponBase(Weapon).WeaponComponents(iter, index)
	{
		if (ArenaPlayerController(Pawn.Controller).TraceComponent(traceLoc, traceNorm, iter.Mesh, origin + direction * 512, origin , , , true))
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
	
	if (!hit && ArenaPlayerController(Pawn.Controller).TraceComponent(traceLoc, traceNorm, ArenaWeaponBase(Weapon).Mesh, origin + direction * 512, origin , , , true))
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

function LookUp(out vector loc, out rotator rot)
{
	rot.Pitch = 16384;
}

event OnMouseMove()
{
	local vector2D mousePos, delta;
	
	mousePos.x = Cursor.GetFloat("x");
	mousePos.y = Cursor.GetFloat("y");
	delta = mousePos - MousePosition;
	
	if (DraggingMouse && !DraggingRightMouse)
	{
		Rotation.Yaw = (Rotation.Yaw + 64 * -delta.x) % 65536;
		Rotation.Roll = (Rotation.Roll + 64 * -delta.y) % 65536;
	}
	else if (DraggingRightMouse)
	{
		WeaponScale = FClamp(WeaponScale + delta.y * 0.01, 0.25, 2.5);
	}
	
	MousePosition = mousePos;
}

event OnMouseClick()
{
	if (SelectedPart > -1)
		GotoSubmenu();
}

event OnMouseDown()
{	
	if (Cursor.GetFloat("x") > 800)
		DraggingMouse = true;
}

event OnMouseUp()
{
	DraggingMouse = false;
}

event OnRightMouseDown()
{
	`log("Right mouse down");
	if (Cursor.GetFloat("x") > 800)
		DraggingRightMouse = true;
}

event OnRightMouseUp()
{
	DraggingRightMouse = false;
}
event OnTextInputClick(GFxClikWidget.EventData ev)
{
	if (!ChangedName)
		NameLabel.SetString("text", Weapon.WeaponName);
	
	ChangedName = true;
	AcceptButton.SetBool("enabled", true);
}

function OnPressAcceptButton(GFxClikWidget.EventData ev)
{
	SaveWeapon();
	ArenaPlayerController(Pawn.Controller).SetWeaponSchematic(WeaponData, OriginalName);
	GFx_CharacterView(Parent).Character.PrimaryWeaponName = WeaponData.WeaponName;
	
	GFx_CharacterView(Parent).BuildPrimanyWeaponInfo();
	
	OnClose = GoBack;
    CloseMenu();
}

function OnPressCancelButton(GFxClikWidget.EventData ev)
{
	OnClose = GoBack;
	CloseMenu();
}

function CloseMenu()
{
	ActionScriptVoid("_root.CloseMenu");
}

function CloseAnimCompleted()
{
	OnClose();
}

function GotoSubmenu()
{
	local GFx_WESubmenu submenu;
	
	submenu = new class'Arena.GFx_WESubmenu';
	submenu.bEnableGammaCorrection = FALSE;
	submenu.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(PlayerController(Pawn.Controller).Player));
	submenu.SetTimingMode(TM_Real);
	submenu.Parent = self;
	
	submenu.LightEnvironment = MenuLightEnvironment;
	
	if (SelectedPart == 0)
		submenu.BaseClass = ArenaWeaponBase(Weapon).Class;
	else
		submenu.ComponentClass = ArenaWeaponBase(Weapon).WeaponComponents[SelectedPart - 1].Class;
	
	PartTooltip.SetVisible(false);
	StatTooltip.SetVisible(false);
	Cursor.SetVisible(false);
	Weapon.HideWeapon(true);

	AddMuzzle.SetVisible(false);
	AddSide.SetVisible(false);
	AddUnder.SetVisible(false);
	AddOptics.SetVisible(false);
	AddStock.SetVisible(false);

	submenu.Start();
	submenu.PlayOpenAnimation();
}

function GoBack()
{
	Pawn.SetMenu(Parent);

	Close();
	
	Parent.PlayOpenAnimation();
	
	ArenaPlayerController(Pawn.Controller).OnSetPlayerViewpoint = GFx_CharacterView(Parent).LookUp;
	
	Weapon.Destroy();
}

function EnableMenu()
{
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

}

function OnPressAddStockButton(GFxClikWidget.EventData ev)
{
	SelectedPart = 1;
}

function OnPressAddMuzzleButton(GFxClikWidget.EventData ev)
{
	SelectedPart = 3;
}

function OnPressAddOpticsButton(GFxClikWidget.EventData ev)
{
	SelectedPart = 4;
}

function OnPressAddUnderButton(GFxClikWidget.EventData ev)
{
	SelectedPart = 5;
}

function OnPressAddSideButton(GFxClikWidget.EventData ev)
{
	SelectedPart = 6;
}

function OnDropdownIndexChanged(string ddlName, int index)
{
	ChangedWeapon = true;
	FireModeIndex = index;
	AcceptButton.SetBool("enabled", true);
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

function ArenaWeapon CreateWeapon()
{
	local ArenaWeaponBase base;
	local Wp_Stock stock;
	local Wp_Barrel barrel;
	local Wp_Muzzle muzzle;
	local Wp_Optics optics;
	local Wp_SideAttachment side;
	local Wp_UnderAttachment under;
	
	base = Pawn.Spawn(WeaponData.BaseClass, None, , Pawn.Location + WeaponOffset, rot(0, 0, 0));
	base.WeaponName = WeaponData.WeaponName;

	stock = Wp_Stock(Pawn.spawn(WeaponData.Components[WCStock], base, , base.Location, base.Rotation));
	barrel = Wp_Barrel(Pawn.spawn(WeaponData.Components[WCBarrel], base, , base.Location, base.Rotation));
	muzzle = Wp_Muzzle(Pawn.spawn(WeaponData.Components[WCMuzzle], base, , base.Location, base.Rotation));
	optics = Wp_Optics(Pawn.spawn(WeaponData.Components[WCOptics], base, , base.Location, base.Rotation));
	side = Wp_SideAttachment(Pawn.spawn(WeaponData.Components[WCSideAttachment], base, , base.Location, base.Rotation));
	under = Wp_UnderAttachment(Pawn.spawn(WeaponData.Components[WCUnderAttachment], base, , base.Location, base.Rotation));
	
	base.AttachStock(stock);
	base.AttachBarrel(barrel);
	base.AttachMuzzle(muzzle);
	base.AttachOptics(optics);
	base.AttachSide(side);
	base.AttachUnder(under);
	
	base.SetFireModes(WeaponData.FireModes);
	
	return base;
}

function SaveWeapon()
{
	local int i;
	
	WeaponData.WeaponName = Repl(NameLabel.GetString("text"), "\"", "");
	
	WeaponData.BaseClass = class<ArenaWeaponBase>(Weapon.class);
	
	for(i = 0; i < ArenaWeaponBase(Weapon).WeaponComponents.Length; i++)
		WeaponData.Components[i] = ArenaWeaponBase(Weapon).WeaponComponents[i].class;
	
	WeaponData.FireModes = GetFireModes();
}

function SetWeaponParameters()
{
	local ArenaWeaponComponent iter;
	local MaterialInstanceConstant mat;
	
	ArenaWeaponBase(Weapon).Mesh.SetDepthPriorityGroup(SDPG_Foreground);
	ArenaWeaponBase(Weapon).Mesh.SetOnlyOwnerSee(false);
	
	if (ArenaWeaponBase(Weapon).ClipMesh != None)
	{
		ArenaWeaponBase(Weapon).ClipMesh.SetDepthPriorityGroup(SDPG_Foreground);
		ArenaWeaponBase(Weapon).ClipMesh.SetOnlyOwnerSee(false);
	}
	
	foreach ArenaWeaponBase(Weapon).WeaponComponents(iter)
	{
		iter.Mesh.SetDepthPriorityGroup(SDPG_Foreground);
		iter.Mesh.SetOnlyOwnerSee(false);
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
	
	return "";
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
	Rotation=()
	WeaponOffset=(X=0,Y=30,Z=128)
	WeaponScale=0.5
	SpinRate=0.05
	HighlightPulseRate=2.5
	SelectedPart=-1
	bCaptureInput=true
	bCaptureMouseInput=true
	
	FocusIgnoreKeys[0]=Escape
}