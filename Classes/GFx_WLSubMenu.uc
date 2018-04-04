/*******************************************************************************
	GFx_WLSubMenu

	Creation date: 30/05/2013 04:53
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * A weapon locker submenu that is used to show off individual weapon parts.
 */
class GFx_WLSubMenu extends GFx_Menu;

var ArenaPlayerController Viewer;

var GFx_WeaponLocker Parent;

var GFxObject NameLabel, BaseNameLabel, Cursor, BaseUI, ComponentUI, AcceptBW, CancelBW, StatsContainer;

var GFx_StatModDisplay ComponentStatMod, BaseStatMod;

var GFx_WeapDescription ComponentDescription;

var GFx_BaseDescription BaseDescription;

var GFx_Library ComponentLibrary;

var GFx_Tooltip Tooltip;

/**
 * The accept and cancel buttons.
 */
var GFxClikWidget AcceptButton, CancelButton;

/**
 * A list of weapon stats menu items.
 */
var array<GFx_StatBarComparer> Stats;

var DynamicLightEnvironmentComponent LightEnvironment;

var class<ArenaWeaponBase> BaseClass;

var class<ArenaWeaponComponent> ComponentClass;

var ArenaWeaponBase Base;

var ArenaWeaponComponent Component;

var vector WeaponOffset;

var float WeaponScale;

var float SpinRate;

var bool AcceptSelection;

/**
 * Indicates that the player has changed the currently selected component.
 */
var bool ChangedSelection;

function bool Start(optional bool StartPaused = false)
{	
	local ArenaWeaponBase currBase;
	local int i;
	
	super.Start(StartPaused);
			
    Advance(0);

	Cursor = GetVariableObject("_root.cursor");
	BaseUI = GetVariableObject("_root.baseUI");
	ComponentUI = GetVariableObject("_root.componentUI");
	StatsContainer = GetVariableObject("_root.stats");
	BaseNameLabel = BaseUI.GetObject("base_name_label");	
	NameLabel = ComponentUI.GetObject("nameLabel");
	
	AcceptButton = GFxClikWidget(GetVariableObject("_root.acceptButton", class'GFxClikWidget'));
	CancelButton = GFxClikWidget(GetVariableObject("_root.cancelButton", class'GFxClikWidget'));

	//AcceptButton.AddEventListener('CLIK_click', OnPressAcceptButton);
	CancelButton.AddEventListener('CLIK_click', OnPressCancelButton);
	
	Tooltip = GFx_Tooltip(GetVariableObject("_root.tooltip", class'GFx_Tooltip'));
	BaseStatMod = GFx_StatModDisplay(BaseUI.GetObject("base_stats", class'Arena.GFx_StatModDisplay'));
	BaseDescription = GFx_BaseDescription(BaseUI.GetObject("base_description", class'Arena.GFx_BaseDescription'));
	ComponentStatMod = GFx_StatModDisplay(ComponentUI.GetObject("component_stats", class'Arena.GFx_StatModDisplay'));
	ComponentDescription = GFx_WeapDescription(ComponentUI.GetObject("component_description", class'Arena.GFx_WeapDescription'));
	ComponentLibrary = GFx_Library(GetVariableObject("_root.library", class'Arena.GFx_Library'));
	
	ComponentLibrary.Parent = self;
	ComponentLibrary.Tooltip = Tooltip;
	
	Tooltip.SetVisible(false);
	
	Cursor.SetFloat("x", Parent.Cursor.GetFloat("x"));
	Cursor.SetFloat("y", Parent.Cursor.GetFloat("y"));
	
	Stats.AddItem(GFx_StatBarComparer(StatsContainer.GetObject("weight_stat", class'Arena.GFx_StatBarComparer')));
	Stats.AddItem(GFx_StatBarComparer(StatsContainer.GetObject("accuracy_stat", class'Arena.GFx_StatBarComparer')));
	Stats.AddItem(GFx_StatBarComparer(StatsContainer.GetObject("stability_stat", class'Arena.GFx_StatBarComparer')));
	Stats.AddItem(GFx_StatBarComparer(StatsContainer.GetObject("mobility_stat", class'Arena.GFx_StatBarComparer')));
	Stats.AddItem(GFx_StatBarComparer(StatsContainer.GetObject("recoil_stat", class'Arena.GFx_StatBarComparer')));
	Stats.AddItem(GFx_StatBarComparer(StatsContainer.GetObject("zoom_stat", class'Arena.GFx_StatBarComparer')));
	Stats.AddItem(GFx_StatBarComparer(StatsContainer.GetObject("rof_stat", class'Arena.GFx_StatBarComparer')));
	Stats.AddItem(GFx_StatBarComparer(StatsContainer.GetObject("roc_stat", class'Arena.GFx_StatBarComparer')));
	Stats.AddItem(GFx_StatBarComparer(StatsContainer.GetObject("damage_stat", class'Arena.GFx_StatBarComparer')));

	SetTokens(Viewer.SaveData.BBData.Tokens);
	
	if (BaseClass != None)
	{
		SpawnNewBase(BaseClass);
		BaseNameLabel.SetText(Base.BaseName);
				
		BaseStatMod.SetBaseDisplay(Base.Stats);
		BaseDescription.SetDisplay(Base);
		
		ComponentLibrary.BuildBaseLibrary(Base);
		ComponentLibrary.ScrollList.AddEventListener('CLIK_itemRollOver', OnMouseHover);
		ComponentLibrary.ScrollList.AddEventListener('CLIK_itemRollOut', OnMouseLeave);
		ComponentLibrary.ScrollList.AddEventListener('CLIK_itemClick', OnItemClicked);
		
		currBase = ArenaWeaponBase(Parent.Weapon);
		
		for (i = 0; i < Stats.Length; i++)
		{
			Stats[i].SetStatValue(Base.Stats.Values[i] > -1 ? Base.Stats.Values[i] : Base.Stats.GetGGC(i), Parent.Weapon.Stats.GetGGCMax(i), currBase.Stats.DefaultValues[i] > -1 ? currBase.Stats.DefaultValues[i] : Base.Stats.GetGGC(i));
		}
	}
	else if (ComponentClass != None)
	{	
		for (i = 0; i < Stats.Length; i++)
		{
			Stats[i].SetStatName(GetStatName(i));
			
			if (i > 0)
				Stats[i].SetStatValue(Parent.Weapon.Stats.Values[i], Parent.Weapon.Stats.GetGGCMax(i), Parent.Weapon.Stats.Values[i]);
			else
				Stats[i].SetStatValue(ArenaWeaponBase(Parent.Weapon).GetWeight(), 25, ArenaWeaponBase(Parent.Weapon).GetWeight());
		}
		
		SpawnNewComponent(ComponentClass);
		NameLabel.SetText(Component.ComponentName);
		
		ComponentStatMod.SetComponentDisplay(Component.StatMod);
		ComponentDescription.SetDisplay(Component);
		
		ComponentLibrary.BuildComponentLibrary(ArenaWeaponBase(Parent.Weapon), Component);
		ComponentLibrary.ScrollList.AddEventListener('CLIK_itemRollOver', OnMouseHover);
		ComponentLibrary.ScrollList.AddEventListener('CLIK_itemRollOut', OnMouseLeave);
		ComponentLibrary.ScrollList.AddEventListener('CLIK_itemClick', OnItemClicked);
	}
	
	
	return true;
}

function Update(float dt)
{
	local rotator r;
	
	if (Base != None)
		r = Base.Rotation;
	else if (Component != None)
		r = Component.Rotation;
		
	r.Pitch = 0;
	r.Yaw += 65536 * dt * SpinRate;
	r.Yaw = r.Yaw % 65536;
	
	if (Base != None)
		Base.SetRotation(r);
	else if (Component != None)
		Component.SetRotation(r);
}

event OnClose()
{
	if (Base != None)
		Base.Destroy();
	else if (Component != None)
		Component.Destroy();
}

function AcceptButtonPressed()
{
	if (Component != None)
	{
		Component.Mesh.SetHidden(true);
	}
	else if (Base != None)
	{
		Base.Mesh.SetHidden(true);
		
		if (Base.ClipMesh != None)
			Base.ClipMesh.SetHidden(true);
	}
	
	AcceptSelection = true;
	
	CloseMenu();
}

function OnPressCancelButton(GFxClikWidget.EventData ev)
{
	if (Component != None)
	{
		Component.Mesh.SetHidden(true);
	}
	else if (Base != None)
	{
		Base.Mesh.SetHidden(true);
		
		if (Base.ClipMesh != None)
			Base.ClipMesh.SetHidden(true);
	}
		
	CloseMenu();
}

function OnMouseHover(GFxClikWidget.EventData ev)
{
	local class<ArenaWeaponBase> selectedBase;
	local ArenaWeaponBase currBase;
	local ArenaWeaponComponent baseComponent;
	local GFxObject item;
	local float diff;
	local int index;
	local int i;
	
	Tooltip.SetVisible(true);
	
	item = ev._this;
	index = item.GetInt("index");

	if (Base != None)
	{
		currBase = ArenaWeaponBase(Parent.Weapon);
		selectedBase = ComponentLibrary.ValidBases[ComponentLibrary.CurrentType].Bases[index];
		
		Tooltip.SetTooltipDescription(selectedBase.default.BaseDescription);
		//Tooltip.ClearStats();
		
		for (i = 0; i < 9; i++)
		{
			if (selectedBase.default.Stats.Values[i] != Base.Stats.Values[i])
			{
				diff = selectedBase.default.Stats.Values[i] - Base.Stats.Values[i];
				
				//Tooltip.AddTooltipStat(GetStatName(i), selectedBase.default.Stats.Values[i], diff);
			}
		}
		
		for (i = 0; i < Stats.Length; i++)
		{
			Stats[i].SetStatValue(selectedBase.default.Stats.Values[i] > -1 ? selectedBase.default.Stats.Values[i] : Base.Stats.GetGGC(i), Base.Stats.GetGGCMax(i), currBase.Stats.DefaultValues[i] > -1 ? currBase.Stats.DefaultValues[i] : Base.Stats.GetGGC(i));
		}
	}
	else if (Component != None)
	{
		baseComponent = GetBaseComponent(Component);
		
		Tooltip.SetTooltipDescription(ComponentLibrary.ValidComponents[index].default.ComponentDescription);
		//Tooltip.ClearStats();
		
		for (i = 0; i < 9; i++)
		{
			if (ComponentLibrary.ValidComponents[index].default.StatMod.ValueMods[i] != Component.StatMod.ValueMods[i])
			{
				diff = ComponentLibrary.ValidComponents[index].default.StatMod.ValueMods[i] - Component.StatMod.ValueMods[i];
				
				//Tooltip.AddTooltipStat(GetStatName(i), ComponentLibrary.ValidComponents[index].default.StatMod.ValueMods[i], diff);
			}
		}
		
		for (i = 0; i < Stats.Length; i++)
		{
			if (i > 0)
				Stats[i].SetStatValue(Parent.Weapon.Stats.Values[i] * ComponentLibrary.ValidComponents[index].default.StatMod.ValueMods[i] / baseComponent.StatMod.ValueMods[i], Parent.Weapon.Stats.GetGGCMax(i), Parent.Weapon.Stats.Values[i]);
			else
				Stats[i].SetStatValue(ArenaWeaponBase(Parent.Weapon).GetWeight() - baseComponent.Weight + ComponentLibrary.ValidComponents[index].default.Weight, 25, ArenaWeaponBase(Parent.Weapon).GetWeight());
		}
	}
}

function OnMouseLeave(GFxClikWidget.EventData ev)
{
	local ArenaWeaponBase currBase;
	local ArenaWeaponComponent baseComponent;
	local int i;
	
	Tooltip.SetVisible(false);
	
	if (Base != None)
	{
		currBase = ArenaWeaponBase(Parent.Weapon);
		
		for (i = 0; i < Stats.Length; i++)
		{
			Stats[i].SetStatValue(Base.Stats.Values[i] > -1 ? Base.Stats.Values[i] : Base.Stats.GetGGC(i), Parent.Weapon.Stats.GetGGCMax(i), currBase.Stats.DefaultValues[i] > -1 ? currBase.Stats.DefaultValues[i] : Base.Stats.GetGGC(i));
		}
	}
	else if (Component != None)
	{
		baseComponent = GetBaseComponent(Component);
		
		for (i = 0; i < Stats.Length; i++)
		{
			if (i > 0)
				Stats[i].SetStatValue(Parent.Weapon.Stats.Values[i] * Component.StatMod.ValueMods[i] / baseComponent.StatMod.ValueMods[i], Parent.Weapon.Stats.GetGGCMax(i), Parent.Weapon.Stats.Values[i]);
			else
				Stats[i].SetStatValue(ArenaWeaponBase(Parent.Weapon).GetWeight() - baseComponent.Weight + Component.Weight, 25, ArenaWeaponBase(Parent.Weapon).GetWeight());
		}
	}
}

function OnItemClicked(GFxClikWidget.EventData ev)
{
	local int index;
	
	index = ev._this.GetInt("index");

	if (Base != None)
	{
		Base.Destroy();
		
		SpawnNewBase(ComponentLibrary.ValidBases[ComponentLibrary.CurrentType].Bases[index]);
		BaseNameLabel.SetText(Base.BaseName);
		
		BaseStatMod.SetBaseDisplay(Base.Stats);
		BaseDescription.SetDisplay(Base);
				
		if (Viewer.SaveData.WeapData.BoughtBases.Find(ComponentLibrary.ValidBases[ComponentLibrary.CurrentType].Bases[index]) > -1)
			AcceptButton.SetBool("enabled", true);
			
		ChangedSelection = true;		
	}
	else if (Component != None)
	{
		Component.Destroy();
		
		SpawnNewComponent(ComponentLibrary.ValidComponents[index]);
		NameLabel.SetText(Component.ComponentName);
		
		ComponentStatMod.SetComponentDisplay(Component.StatMod);
		ComponentDescription.SetDisplay(Component);
		
		if (Viewer.SaveData.WeapData.BoughtComponents.Find(ComponentLibrary.ValidComponents[index]) > -1)
			AcceptButton.SetBool("enabled", true);
			
		ChangedSelection = true;
	}
}

function ComponentPurchased(int index)
{
	if (Base != None)
	{
		Viewer.SaveData.WeapData.BoughtBases.AddItem(ComponentLibrary.ValidBases[ComponentLibrary.CurrentType].Bases[index]);
		AcceptButton.SetBool("enabled", true);
			
		Viewer.SpendBBTokens(Base.default.Cost);
		
		ComponentLibrary.BuildBaseLibrary(Base);
		
		ChangedSelection = true;		
	}
	else if (Component != None)
	{
		
		Viewer.SaveData.WeapData.BoughtComponents.AddItem(ComponentLibrary.ValidComponents[index]);
		AcceptButton.SetBool("enabled", true);
		
		Viewer.SpendBBTokens(Component.default.Cost);
		
		ComponentLibrary.BuildComponentLibrary(ArenaWeaponBase(Parent.Weapon), Component);
		
		ChangedSelection = true;
	}
	
	SetTokens(Viewer.SaveData.BBData.Tokens);
}

function FillLibrary(array<GFxObject> list, string sel, string category, optional int baseSelection = -1)
{
	ActionScriptVoid("_root.FillLibrary");
}

function CloseMenu()
{
	ActionScriptVoid("_root.CloseMenu");
}

function SetTokens(int tokens)
{
	ActionScriptVoid("_root.SetTokens");
}

function CloseAnimCompleted()
{
	if (AcceptSelection)
	{
		if (Component != None)
			Parent.ChangeWeaponComponent(Component.Class);
		else
			Parent.ChangeWeaponBase(Base.Class);
	}
	
	Parent.InterceptEscape();
	Parent.Submenu.Close();
}

function SpawnNewBase(class<ArenaWeaponBase> c)
{
	Base = Viewer.Spawn(c, None, , Viewer.Pawn.Location + (WeaponOffset >> Viewer.Rotation), Viewer.Rotation);
		
	Base.AttachComponent(Base.Mesh);
	Base.EnsureWeaponOverlayComponentLast();
	Base.SetHidden(false);
	Base.Mesh.SetLightEnvironment(LightEnvironment);
	Base.Mesh.SetDepthPriorityGroup(SDPG_Foreground);
	Base.Mesh.SetOnlyOwnerSee(false);
	Base.SetDrawScale(WeaponScale);
	
	if (Base.ClipMesh != None)
	{
		Base.ClipMesh.SetDepthPriorityGroup(SDPG_Foreground);
		Base.ClipMesh.SetOnlyOwnerSee(false);
		Base.AttachClip();
		Base.ClipMesh.SetLightEnvironment(LightEnvironment);
	}
}

function SpawnNewComponent(class<ArenaWeaponComponent> c)
{
	Component = Viewer.Spawn(c, None, , Viewer.Pawn.Location + (WeaponOffset >> Viewer.Rotation), Viewer.Rotation);
		
	Component.AttachComponent(Component.Mesh);
	Component.SetHidden(false);
	Component.Mesh.SetLightEnvironment(LightEnvironment);
	Component.Mesh.SetDepthPriorityGroup(SDPG_Foreground);
	Component.Mesh.SetOnlyOwnerSee(false);
	Component.SetDrawScale(WeaponScale);
}

function ArenaWeaponComponent GetBaseComponent(ArenaWeaponComponent comp)
{
	if (comp.IsA('Wp_Stock'))
		return ArenaWeaponBase(Parent.Weapon).WeaponComponents[WCStock];
	else if (comp.IsA('Wp_Barrel'))
		return ArenaWeaponBase(Parent.Weapon).WeaponComponents[WCBarrel];
	else if (comp.IsA('Wp_Muzzle'))
		return ArenaWeaponBase(Parent.Weapon).WeaponComponents[WCMuzzle];
	else if (comp.IsA('Wp_Optics'))
		return ArenaWeaponBase(Parent.Weapon).WeaponComponents[WCOptics];
	else if (comp.IsA('Wp_UnderAttachment'))
		return ArenaWeaponBase(Parent.Weapon).WeaponComponents[WCUnderAttachment];
	else if (comp.IsA('Wp_SideAttachment'))
		return ArenaWeaponBase(Parent.Weapon).WeaponComponents[WCSideAttachment];
	else
		return None;
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

defaultproperties
{
	MovieInfo=SwfMovie'ArenaUI.WLSubmenu'
	
	WeaponOffset=(X=48, Y=20, Z=68)
	WeaponScale=0.5
	SpinRate=0.15
	
	bCaptureMouseInput=true
}