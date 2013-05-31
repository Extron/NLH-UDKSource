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

var GFx_WLSubMenu Submenu;

/**
 * The menu container for the weapon stats.
 */
var GFxObject StatsContainer, ValuesContainer, NameLabel, Cursor;

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
var GFxClikWidget AcceptButton, CancelButton;

/**
 * A list of weapon stats menu items.
 */
var array<GFx_StatBar> Stats;

/**
 * A list of weapon stats menu items.
 */
var array<GFx_ValueDisplay> Values;

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


function bool Start(optional bool StartPaused = false)
{	
	local int i;
	local rotator r;
	
	super.Start(StartPaused);
			
    Advance(0);

	StatsContainer = GetVariableObject("_root.details.stats");
	ValuesContainer = GetVariableObject("_root.details.values");
	NameLabel = GetVariableObject("_root.details.name_label.label");
	Cursor = GetVariableObject("_root.cursor");
	
	PartTooltip = GFx_Tooltip(GetVariableObject("_root.part_tooltip", class'GFx_Tooltip'));
	StatTooltip = GFx_Tooltip(GetVariableObject("_root.stat_tooltip", class'GFx_Tooltip'));
	
	AcceptBW = GetVariableObject("_root.accept_button");
	CancelBW = GetVariableObject("_root.cancel_button");
	
	AcceptButton = GFxClikWidget(AcceptBW.GetObject("button", class'GFxClikWidget'));
	CancelButton = GFxClikWidget(CancelBW.GetObject("button", class'GFxClikWidget'));

	AcceptButton.AddEventListener('CLIK_click', OnPressAcceptButton);
	CancelButton.AddEventListener('CLIK_click', OnPressCancelButton);
	
	Stats.AddItem(GFx_StatBar(StatsContainer.GetObject("weight_stat", class'Arena.GFx_StatBar')));
	Stats.AddItem(GFx_StatBar(StatsContainer.GetObject("accuracy_stat", class'Arena.GFx_StatBar')));
	Stats.AddItem(GFx_StatBar(StatsContainer.GetObject("stability_stat", class'Arena.GFx_StatBar')));
	Stats.AddItem(GFx_StatBar(StatsContainer.GetObject("mobility_stat", class'Arena.GFx_StatBar')));
	Stats.AddItem(GFx_StatBar(StatsContainer.GetObject("recoil_stat", class'Arena.GFx_StatBar')));
	Stats.AddItem(GFx_StatBar(StatsContainer.GetObject("zoom_stat", class'Arena.GFx_StatBar')));
	Stats.AddItem(GFx_StatBar(StatsContainer.GetObject("rof_stat", class'Arena.GFx_StatBar')));
	Stats.AddItem(GFx_StatBar(StatsContainer.GetObject("roc_stat", class'Arena.GFx_StatBar')));
	Stats.AddItem(GFx_StatBar(StatsContainer.GetObject("damage_stat", class'Arena.GFx_StatBar')));
	
	Values.AddItem(GFx_ValueDisplay(ValuesContainer.GetObject("weapon_type_value", class'Arena.GFx_ValueDisplay')));
	Values.AddItem(GFx_ValueDisplay(ValuesContainer.GetObject("weapon_size_value", class'Arena.GFx_ValueDisplay')));
	Values.AddItem(GFx_ValueDisplay(ValuesContainer.GetObject("fire_mode_value", class'Arena.GFx_ValueDisplay')));
	Values.AddItem(GFx_ValueDisplay(ValuesContainer.GetObject("mag_value", class'Arena.GFx_ValueDisplay')));
	Values.AddItem(GFx_ValueDisplay(ValuesContainer.GetObject("damage_value", class'Arena.GFx_ValueDisplay')));
	Values.AddItem(GFx_ValueDisplay(ValuesContainer.GetObject("reload_value", class'Arena.GFx_ValueDisplay')));
	Values.AddItem(GFx_ValueDisplay(ValuesContainer.GetObject("equip_value", class'Arena.GFx_ValueDisplay')));
	Values.AddItem(GFx_ValueDisplay(ValuesContainer.GetObject("clip_size_value", class'Arena.GFx_ValueDisplay')));
	Values.AddItem(GFx_ValueDisplay(ValuesContainer.GetObject("bloom_value", class'Arena.GFx_ValueDisplay')));
	
	if (ArenaPlayerController(GetPC()) != None)
	{
		`log("LE" @ MenuLightEnvironment);
		
		
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
		
		Weapon.AttachComponent(UpLight);
		Weapon.AttachComponent(LeftLight);
		Weapon.AttachComponent(RightLight);

	}

	NameLabel.SetText("\"" $ Weapon.WeaponName $ "\"");
	
	for (i = 0; i < Stats.Length; i++)
	{
		Stats[i].SetStatName(GetStatName(i));
		
		if (i > 0)
			Stats[i].SetStatValue(Weapon.Stats.Values[i], Weapon.Stats.GetGGCMax(i));
		else
			Stats[i].SetStatValue(ArenaWeaponBase(Weapon).GetWeight(), 25);
	}

	for (i = 0; i < Values.Length; i++)
	{
		Values[i].SetValueName(GetValueName(i) $ ":");
		SetValue(Values[i], i);
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
	local vector2D mousePos;
	local vector origin, direction;
	local vector traceLoc, traceNorm;
	
	if (Submenu != None && Submenu.bMovieIsOpen)
	{
		Submenu.PostRender();
		return;
	}
	
	mousePos.x = Cursor.GetFloat("x") * Viewer.MyHUD.SizeX / NativeWidth;
	mousePos.y = Cursor.GetFloat("y") * Viewer.MyHUD.SizeY / NativeHeight;
	
	Viewer.MyHUD.Canvas.DeProject(mousePos, origin, direction);
	
	//`log("Origin" @ origin @ "Pawn location" @ Viewer.Pawn.Location @ "Weapon Location" @ Weapon.Location);
	
	//traceActor = Viewer.Trace(traceLoc, traceNorm, origin + direction * 512, origin , true);
	ArenaWeaponBase(Weapon).Mesh.SetTraceBlocking(true, true);
	
	if (Viewer.TraceComponent(traceLoc, traceNorm, ArenaWeaponBase(Weapon).Mesh, origin + direction * 512, origin , , , true))
	{
		if (SelectedPart > -1)
			WeaponMaterials[SelectedPart].SetScalarParameterValue('EmissionFactor', 0);
			
		SelectedPart = 0;
		
		PartTooltip.SetVisible(true);
		StatTooltip.SetVisible(true);
		SetStatTooltip(StatTooltip, Weapon.default.Stats.Values, -1);
		
		PartTooltip.SetTooltipTitle(ArenaWeaponBase(Weapon).ArenaWeaponBaseName);
		PartTooltip.SetTooltipBody(ArenaWeaponBase(Weapon).BaseDescription);
	}
	else if (Viewer.TraceComponent(traceLoc, traceNorm, ArenaWeaponBase(Weapon).Stock.Mesh, origin + direction * 512, origin , , , true))
	{
		if (SelectedPart > -1)
			WeaponMaterials[SelectedPart].SetScalarParameterValue('EmissionFactor', 0);
			
		SelectedPart = 1;
		
		PartTooltip.SetVisible(true);
		StatTooltip.SetVisible(true);
		SetStatTooltip(StatTooltip, ArenaWeaponBase(Weapon).Stock.StatMod.ValueMods, 1, ArenaWeaponBase(Weapon).Stock.Weight);
		
		PartTooltip.SetTooltipTitle(ArenaWeaponBase(Weapon).Stock.ComponentName);
		PartTooltip.SetTooltipBody(ArenaWeaponBase(Weapon).Stock.ComponentDescription);
	}
	else if (Viewer.TraceComponent(traceLoc, traceNorm, ArenaWeaponBase(Weapon).Barrel.Mesh, origin + direction * 512, origin , , , true))
	{
		if (SelectedPart > -1)
			WeaponMaterials[SelectedPart].SetScalarParameterValue('EmissionFactor', 0);
			
		SelectedPart = 2;
		
		PartTooltip.SetVisible(true);
		StatTooltip.SetVisible(true);
		SetStatTooltip(StatTooltip, ArenaWeaponBase(Weapon).Barrel.StatMod.ValueMods, 1, ArenaWeaponBase(Weapon).Barrel.Weight);
		
		PartTooltip.SetTooltipTitle(ArenaWeaponBase(Weapon).Barrel.ComponentName);
		PartTooltip.SetTooltipBody(ArenaWeaponBase(Weapon).Barrel.ComponentDescription);
	}
	else if (Viewer.TraceComponent(traceLoc, traceNorm, ArenaWeaponBase(Weapon).Muzzle.Mesh, origin + direction * 512, origin , , , true))
	{
		if (SelectedPart > -1)
			WeaponMaterials[SelectedPart].SetScalarParameterValue('EmissionFactor', 0);
			
		SelectedPart = 3;
		
		PartTooltip.SetVisible(true);
		StatTooltip.SetVisible(true);
		SetStatTooltip(StatTooltip, ArenaWeaponBase(Weapon).Muzzle.StatMod.ValueMods, 1, ArenaWeaponBase(Weapon).Muzzle.Weight);
		
		PartTooltip.SetTooltipTitle(ArenaWeaponBase(Weapon).Muzzle.ComponentName);
		PartTooltip.SetTooltipBody(ArenaWeaponBase(Weapon).Muzzle.ComponentDescription);
	}
	else if (Viewer.TraceComponent(traceLoc, traceNorm, ArenaWeaponBase(Weapon).Optics.Mesh, origin + direction * 512, origin , , , true))
	{
		if (SelectedPart > -1)
			WeaponMaterials[SelectedPart].SetScalarParameterValue('EmissionFactor', 0);
			
		SelectedPart = 4;
		
		PartTooltip.SetVisible(true);
		StatTooltip.SetVisible(true);
		SetStatTooltip(StatTooltip, ArenaWeaponBase(Weapon).Optics.StatMod.ValueMods, 1, ArenaWeaponBase(Weapon).Optics.Weight);
		
		PartTooltip.SetTooltipTitle(ArenaWeaponBase(Weapon).Optics.ComponentName);
		PartTooltip.SetTooltipBody(ArenaWeaponBase(Weapon).Optics.ComponentDescription);
	}
	else if (Viewer.TraceComponent(traceLoc, traceNorm, ArenaWeaponBase(Weapon).Under.Mesh, origin + direction * 512, origin , , , true))
	{
		if (SelectedPart > -1)
			WeaponMaterials[SelectedPart].SetScalarParameterValue('EmissionFactor', 0);
			
		SelectedPart = 5;
		
		PartTooltip.SetVisible(true);
		StatTooltip.SetVisible(true);
		SetStatTooltip(StatTooltip, ArenaWeaponBase(Weapon).Under.StatMod.ValueMods, 1, ArenaWeaponBase(Weapon).Under.Weight);
		
		PartTooltip.SetTooltipTitle(ArenaWeaponBase(Weapon).Under.ComponentName);
		PartTooltip.SetTooltipBody(ArenaWeaponBase(Weapon).Under.ComponentDescription);
	}
	else if (Viewer.TraceComponent(traceLoc, traceNorm, ArenaWeaponBase(Weapon).Side.Mesh, origin + direction * 512, origin , , , true))
	{
		if (SelectedPart > -1)
			WeaponMaterials[SelectedPart].SetScalarParameterValue('EmissionFactor', 0);
			
		SelectedPart = 6;
		
		PartTooltip.SetVisible(true);
		StatTooltip.SetVisible(true);
		SetStatTooltip(StatTooltip, ArenaWeaponBase(Weapon).Side.StatMod.ValueMods, 1, ArenaWeaponBase(Weapon).Side.Weight);
		
		PartTooltip.SetTooltipTitle(ArenaWeaponBase(Weapon).Side.ComponentName);
		PartTooltip.SetTooltipBody(ArenaWeaponBase(Weapon).Side.ComponentDescription);
	}
	else
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
	if (SelectedPart > -1)
	{
		Submenu = new class'Arena.GFx_WLSubmenu';
		Submenu.bEnableGammaCorrection = FALSE;
		Submenu.LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocalPlayer(Viewer.Player));
		Submenu.SetTimingMode(TM_Real);
		Submenu.Parent = self;
		Submenu.Viewer = Viewer;
		Submenu.LightEnvironment = MenuLightEnvironment;
		
		switch (SelectedPart)
		{
		case 0:
			Submenu.BaseClass = ArenaWeaponBase(Weapon).Class;
			break;
			
		case 1:
			Submenu.ComponentClass = ArenaWeaponBase(Weapon).Stock.Class;
			break;
			
		case 2:
			Submenu.ComponentClass = ArenaWeaponBase(Weapon).Barrel.Class;
			break;
			
		case 3:
			Submenu.ComponentClass = ArenaWeaponBase(Weapon).Muzzle.Class;
			break;
			
		case 4:
			Submenu.ComponentClass = ArenaWeaponBase(Weapon).Optics.Class;
			break;
			
		case 5:
			Submenu.ComponentClass = ArenaWeaponBase(Weapon).Under.Class;
			break;
			
		case 6:
			Submenu.ComponentClass = ArenaWeaponBase(Weapon).Side.Class;
			break;
			
		}
		
		PartTooltip.SetVisible(false);
		StatTooltip.SetVisible(false);
		Cursor.SetVisible(false);
		ArenaWeaponBase(Weapon).SetHidden(true);
		ArenaWeaponBase(Weapon).Stock.SetHidden(true);
		ArenaWeaponBase(Weapon).Barrel.SetHidden(true);
		ArenaWeaponBase(Weapon).Muzzle.SetHidden(true);
		ArenaWeaponBase(Weapon).Optics.SetHidden(true);
		ArenaWeaponBase(Weapon).Side.SetHidden(true);
		ArenaWeaponBase(Weapon).Under.SetHidden(true);
	
		Submenu.Start();
		Submenu.PlayOpenAnimation();
	}
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
    PlayCloseAnimation();
}

function OnPressCancelButton(GFxClikWidget.EventData ev)
{
	PlayCloseAnimation();
}

function bool InterceptEscape()
{
	if (Submenu != None && Submenu.bMovieIsOpen)
	{
		Submenu.PlayCloseAnimation();
		
		PartTooltip.SetVisible(true);
		StatTooltip.SetVisible(true);
		Cursor.SetVisible(true);
		ArenaWeaponBase(Weapon).SetHidden(false);
		ArenaWeaponBase(Weapon).Stock.SetHidden(false);
		ArenaWeaponBase(Weapon).Barrel.SetHidden(false);
		ArenaWeaponBase(Weapon).Muzzle.SetHidden(false);
		ArenaWeaponBase(Weapon).Optics.SetHidden(false);
		ArenaWeaponBase(Weapon).Side.SetHidden(false);
		ArenaWeaponBase(Weapon).Under.SetHidden(false);
		
		return true;
	}
	
	return false;
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

	`log("Weapon Base" @ ArenaWeaponBase @ "Location" @ ArenaWeaponBase.Location);
	
	stock = currentWeapon.spawn(ArenaWeaponBase(currentWeapon).Stock.Class, ArenaWeaponBase, , ArenaWeaponBase.Location, ArenaWeaponBase.Rotation);
	barrel = currentWeapon.spawn(ArenaWeaponBase(currentWeapon).Barrel.Class, ArenaWeaponBase, , ArenaWeaponBase.Location, ArenaWeaponBase.Rotation);
	muzzle = currentWeapon.spawn(ArenaWeaponBase(currentWeapon).Muzzle.Class, ArenaWeaponBase, , ArenaWeaponBase.Location, ArenaWeaponBase.Rotation);
	optics = currentWeapon.spawn(ArenaWeaponBase(currentWeapon).Optics.Class, ArenaWeaponBase, , ArenaWeaponBase.Location, ArenaWeaponBase.Rotation);
	side = currentWeapon.spawn(ArenaWeaponBase(currentWeapon).Side.Class, ArenaWeaponBase, , ArenaWeaponBase.Location, ArenaWeaponBase.Rotation);
	under = currentWeapon.spawn(ArenaWeaponBase(currentWeapon).Under.Class, ArenaWeaponBase, , ArenaWeaponBase.Location, ArenaWeaponBase.Rotation);
	
	ArenaWeaponBase.AttachStock(stock);
	ArenaWeaponBase.AttachBarrel(barrel);
	ArenaWeaponBase.AttachMuzzle(muzzle);
	ArenaWeaponBase.AttachOptics(optics);
	ArenaWeaponBase.AttachSide(side);
	ArenaWeaponBase.AttachUnder(under);
	
	return ArenaWeaponBase;
}

function SetWeaponParameters()
{
	local MaterialInstanceConstant mat;
	
	ArenaWeaponBase(Weapon).Mesh.SetDepthPriorityGroup(SDPG_Foreground);
	ArenaWeaponBase(Weapon).Stock.Mesh.SetDepthPriorityGroup(SDPG_Foreground);
	ArenaWeaponBase(Weapon).Barrel.Mesh.SetDepthPriorityGroup(SDPG_Foreground);
	ArenaWeaponBase(Weapon).Muzzle.Mesh.SetDepthPriorityGroup(SDPG_Foreground);
	ArenaWeaponBase(Weapon).Optics.Mesh.SetDepthPriorityGroup(SDPG_Foreground);
	ArenaWeaponBase(Weapon).Side.Mesh.SetDepthPriorityGroup(SDPG_Foreground);
	ArenaWeaponBase(Weapon).Under.Mesh.SetDepthPriorityGroup(SDPG_Foreground);
	
	ArenaWeaponBase(Weapon).Mesh.SetOnlyOwnerSee(false);
	ArenaWeaponBase(Weapon).Stock.Mesh.SetOnlyOwnerSee(false);
	ArenaWeaponBase(Weapon).Barrel.Mesh.SetOnlyOwnerSee(false);
	ArenaWeaponBase(Weapon).Muzzle.Mesh.SetOnlyOwnerSee(false);
	ArenaWeaponBase(Weapon).Optics.Mesh.SetOnlyOwnerSee(false);
	ArenaWeaponBase(Weapon).Side.Mesh.SetOnlyOwnerSee(false);
	ArenaWeaponBase(Weapon).Under.Mesh.SetOnlyOwnerSee(false);
	
	ArenaWeaponBase(Weapon).SetDrawScale(WeaponScale);
	ArenaWeaponBase(Weapon).Stock.SetDrawScale(WeaponScale);
	ArenaWeaponBase(Weapon).Barrel.SetDrawScale(WeaponScale);
	ArenaWeaponBase(Weapon).Muzzle.SetDrawScale(WeaponScale);
	ArenaWeaponBase(Weapon).Optics.SetDrawScale(WeaponScale);
	ArenaWeaponBase(Weapon).Side.SetDrawScale(WeaponScale);
	ArenaWeaponBase(Weapon).Under.SetDrawScale(WeaponScale);
	
	mat = new class'MaterialInstanceConstant';
	mat.SetParent(ArenaWeaponBase(Weapon).Mesh.GetMaterial(0));
	mat.SetTextureParameterValue('Emission', Texture'ArenaUI.Textures.HighlightTex');
	ArenaWeaponBase(Weapon).Mesh.SetMaterial(0, mat);
	
	WeaponMaterials.AddItem(mat);
	
	mat = new class'MaterialInstanceConstant';
	mat.SetParent(ArenaWeaponBase(Weapon).Stock.Mesh.GetMaterial(0));
	mat.SetTextureParameterValue('Emission', Texture'ArenaUI.Textures.HighlightTex');
	ArenaWeaponBase(Weapon).Stock.Mesh.SetMaterial(0, mat);
	
	WeaponMaterials.AddItem(mat);
	
	mat = new class'MaterialInstanceConstant';
	mat.SetParent(ArenaWeaponBase(Weapon).Barrel.Mesh.GetMaterial(0));
	mat.SetTextureParameterValue('Emission', Texture'ArenaUI.Textures.HighlightTex');
	ArenaWeaponBase(Weapon).Barrel.Mesh.SetMaterial(0, mat);
	
	WeaponMaterials.AddItem(mat);
	
	mat = new class'MaterialInstanceConstant';
	mat.SetParent(ArenaWeaponBase(Weapon).Muzzle.Mesh.GetMaterial(0));
	mat.SetTextureParameterValue('Emission', Texture'ArenaUI.Textures.HighlightTex');
	ArenaWeaponBase(Weapon).Muzzle.Mesh.SetMaterial(0, mat);
	
	WeaponMaterials.AddItem(mat);
	
	mat = new class'MaterialInstanceConstant';
	mat.SetParent(ArenaWeaponBase(Weapon).Optics.Mesh.GetMaterial(0));
	mat.SetTextureParameterValue('Emission', Texture'ArenaUI.Textures.HighlightTex');
	ArenaWeaponBase(Weapon).Optics.Mesh.SetMaterial(0, mat);
	
	WeaponMaterials.AddItem(mat);
	
	mat = new class'MaterialInstanceConstant';
	mat.SetParent(ArenaWeaponBase(Weapon).Under.Mesh.GetMaterial(0));
	mat.SetTextureParameterValue('Emission', Texture'ArenaUI.Textures.HighlightTex');
	ArenaWeaponBase(Weapon).Under.Mesh.SetMaterial(0, mat);
	
	WeaponMaterials.AddItem(mat);
	
	mat = new class'MaterialInstanceConstant';
	mat.SetParent(ArenaWeaponBase(Weapon).Side.Mesh.GetMaterial(0));
	mat.SetTextureParameterValue('Emission', Texture'ArenaUI.Textures.HighlightTex');
	ArenaWeaponBase(Weapon).Side.Mesh.SetMaterial(0, mat);
	
	WeaponMaterials.AddItem(mat);
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

function SetValue(GFx_ValueDisplay display, int value)
{
	switch (value)
	{
	case 0:
		switch (Weapon.Type)
		{
		case WTRifle:
			display.SetValueString("Rifle");
			break;
			
		case WTShotgun:
			display.SetValueString("Shotgun");
			break;
			
		case WTRocketLauncher:
			display.SetValueString("Rocket Launcher");
			break;
			
		case WTGrenadeLauncher:
			display.SetValueString("Grenade Launcher");
			break;
			
		case WTHardLightRifle:
			display.SetValueString("Photon Emitter");
			break;
			
		case WTBeamRifle:
			display.SetValueString("Particle Beam");
			break;
			
		case WTPlasmaRifle:
			display.SetValueString("Plasma Torch");
			break;
			
		case WTRailGun:
			display.SetValueString("Railgun");
			break;
		}
		break;	
		
		
	case 1:
		switch (Weapon.Size)
		{
		case WSHand:
			display.SetValueString("Handgun");
			break;
			
		case WSSmall:
			display.SetValueString("Small");
			break;
			
		case WSRegular:
			display.SetValueString("Regular");
			break;
			
		case WSLarge:
			display.SetValueString("Large");
			break;
			
		case WSHeavy:
			display.SetValueString("Heavy");
			break;
		}
		break;
		
	case 2:
		switch (Weapon.Mode)
		{
		case FMBoltAction:
			display.SetValueString("Bolt Action");
			break;
			
		case FMSemiAuto:
			display.SetValueString("Semi-automatic");
			break;
			
		case FMBurst:
			display.SetValueString(Weapon.BurstCount $ "-Round Burst");
			break;
			
		case FMFullAuto:
			display.SetValueString("Full-automatic");
			break;
			
		case FMBeam:
			display.SetValueString("Beam");
			break;
		}
		break;
		
	case 3:
		display.SetValueString(ArenaWeaponBase(Weapon).GetZoomLevel() $ "x");
		break;
		
	case 4:
		display.SetValueNumber(Weapon.BaseDamage * Weapon.Stats.GetDamageModifier());
		break;
		
	case 5:
		display.SetValueString(Weapon.GetAvgReloadSpeed() @ "s");
		break;
		
	case 6:
		display.SetValueString(Weapon.GetAvgEquipSpeed() @ "s");
		break;
		
	case 7:
		display.SetValueString(Weapon.MaxClip @ "rounds");
		break;
		
	case 8:
		display.SetValueNumber(Weapon.Stats.GetBloomCost());
		break;
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

defaultproperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=LE
	End Object
	MenuLightEnvironment=LE	
	
	Begin Object Class=PointLightComponent Name=UL
		Brightness=1
		LightColor=(R=225,G=225,B=255,A=255)
		Translation=(Z=25)
		LightEnvironment=LE
	End Object
	
	UpLight=UL
	
	Begin Object Class=PointLightComponent Name=LL
		Brightness=1
		LightColor=(R=255,G=255,B=225,A=255)
		Translation=(X=-25)
		LightEnvironment=LE
	End Object
	
	LeftLight=LL
	
	Begin Object Class=PointLightComponent Name=RL
		Brightness=1
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
	bCaptureMouseInput=true
	//bPauseGameWhileActive=true
}