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
var GFx_Tooltip PartTooltip;

/**
 * The accept and cancel buttons.
 */
var GFxClikWidget SaveButton, CancelButton, AddMuzzle, AddSide, AddUnder, AddOptics, AddStock;

/**
 * The materials of the various weapon parts.  This is used for highlighting selected parts.
 */
var array<MaterialInstanceConstant> WeaponMaterials;

/**
 * Stores the offset of the weapon from the player's location to use when displaying it.
 */
var vector WeaponOffset;

/**
 * Stores the weapon's current rotation in the view window.
 */
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

/**
 * A counter to keep track of time.
 */
var float Counter;

/**
 * Indicates that some aspect of the weapon has changed and that the user's weapon needs to be updated.
 */
var bool ChangedWeapon;

/**
 * Indicates that the weapon's name was changed.
 */
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
	super.Start(StartPaused);
			
    Advance(0);

	OriginalName = WeaponData.WeaponName;
	
	Cursor = GetVariableObject("_root.cursor");
	
	PartTooltip = GFx_Tooltip(GetVariableObject("_root.partTooltip", class'GFx_Tooltip'));
	
	SaveButton = GFxClikWidget(GetVariableObject("_root.saveButton", class'GFxClikWidget'));
	CancelButton = GFxClikWidget(GetVariableObject("_root.cancelButton", class'GFxClikWidget'));
	
	SaveButton.AddEventListener('CLIK_click', OnPressSaveButton);
	CancelButton.AddEventListener('CLIK_click', OnPressCancelButton);
	
	if (ChangedWeapon)
		SaveButton.SetBool("enabled", true);
		
	AddMuzzle = GFxClikWidget(GetVariableObject("_root.addMuzzleButton", class'GFxClikWidget'));	
	AddSide = GFxClikWidget(GetVariableObject("_root.addSideButton", class'GFxClikWidget'));	
	AddUnder = GFxClikWidget(GetVariableObject("_root.addUnderButton", class'GFxClikWidget'));
	AddOptics = GFxClikWidget(GetVariableObject("_root.addOpticsButton", class'GFxClikWidget'));
	AddStock = GFxClikWidget(GetVariableObject("_root.addStockButton", class'GFxClikWidget'));
	
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

	SetEnergyReserve(ArenaWeaponBase(Weapon).GetEnergyUsed(), ArenaWeaponBase(Weapon).EnergyMax);

	SetWeaponName("\"" $ Weapon.WeaponName $ "\"");

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
			//SetStatTooltip(StatTooltip, iter.StatMod.ValueMods, 1, iter.Weight);
			
			PartTooltip.SetTooltipTitle(iter.ComponentName);
			PartTooltip.SetTooltipDescription(iter.ComponentDescription);
			
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
		//SetStatTooltip(StatTooltip, Weapon.default.Stats.Values, -1);
		
		PartTooltip.SetTooltipTitle(ArenaWeaponBase(Weapon).BaseName);
		PartTooltip.SetTooltipDescription(ArenaWeaponBase(Weapon).BaseDescription);
		
		hit = true;
	}
	
	if (!hit)
	{
		if (SelectedPart > -1)
			WeaponMaterials[SelectedPart].SetScalarParameterValue('EmissionFactor', 0);
			
		SelectedPart = -1;
		
		PartTooltip.SetVisible(false);
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
	DraggingMouse = true;
}

event OnMouseUp()
{
	DraggingMouse = false;
}

event OnRightMouseDown()
{
	DraggingRightMouse = true;
}

event OnRightMouseUp()
{
	DraggingRightMouse = false;
}

/*
event OnTextInputClick(GFxClikWidget.EventData ev)
{
	if (!ChangedName)
		NameLabel.SetString("text", Weapon.WeaponName);
	
	ChangedName = true;
	AcceptButton.SetBool("enabled", true);
}*/

function OnPressSaveButton(GFxClikWidget.EventData ev)
{
	SaveWeapon();
	ArenaPlayerController(Pawn.Controller).SetWeaponSchematic(WeaponData, OriginalName);
	GFx_CharacterView(Parent).Character.PrimaryWeaponName = WeaponData.WeaponName;
	
	OnClose = GoBack;
    CloseMenu();
}

function OnPressCancelButton(GFxClikWidget.EventData ev)
{
	OnClose = GoBack;
	CloseMenu();
}

function SetEnergyReserve(float energy, float maxEnergy)
{
	ActionScriptVoid("_root.SetEnergyReserve");
}

function SetWeaponName(string weaponName)
{
	ActionScriptVoid("_root.SetWeaponName");
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
	SaveButton.SetBool("enabled", true);
}

function ChangeWeaponComponent(class<ArenaWeaponComponent> componentClass)
{
	local ArenaWeaponBase base;
	local ArenaWeaponComponent component;
	local MaterialInstanceConstant mat;
	local name socket;
	local int index;
	
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
	
	SaveButton.SetBool("enabled", true);
	ChangedWeapon = true;
}

function ChangeWeaponBase(class<ArenaWeaponBase> baseClass)
{
	local ArenaWeaponBase base;
	local ArenaWeaponComponent iter, component;
	
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
	
	SetEnergyReserve(ArenaWeaponBase(Weapon).GetEnergyUsed(), ArenaWeaponBase(Weapon).EnergyMax);

	SaveButton.SetBool("enabled", true);
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
	
	//WeaponData.WeaponName = Repl(NameLabel.GetString("text"), "\"", "");
	
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

/*
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
}*/

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

	MovieInfo=SwfMovie'ArenaUI.WeaponEditor'
	Rotation=()
	WeaponOffset=(X=0,Y=0,Z=128)
	WeaponScale=0.5
	SpinRate=0.05
	HighlightPulseRate=2.5
	SelectedPart=-1
	bCaptureInput=true
	bCaptureMouseInput=true
	
	FocusIgnoreKeys[0]=Escape
}