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

var GFxObject NameLabel, Cursor, ComponentUI;

var GFx_StatModDisplay ComponentStatMod;

var GFx_WeapDescription ComponentDescription;

var GFx_Library ComponentLibrary;

var DynamicLightEnvironmentComponent LightEnvironment;

var class<ArenaWeaponBase> BaseClass;

var class<ArenaWeaponComponent> ComponentClass;

var ArenaWeaponBase Base;

var ArenaWeaponComponent Component;

var vector WeaponOffset;

var float WeaponScale;

var float SpinRate;

function bool Start(optional bool StartPaused = false)
{	
	super.Start(StartPaused);
			
    Advance(0);
	
	NameLabel = GetVariableObject("_root.name_label");
	Cursor = GetVariableObject("_root.cursor");
	ComponentUI = GetVariableObject("_root.component_ui");
	
	ComponentStatMod = GFx_StatModDisplay(ComponentUI.GetObject("component_stats", class'Arena.GFx_StatModDisplay'));
	ComponentDescription = GFx_WeapDescription(ComponentUI.GetObject("component_description", class'Arena.GFx_WeapDescription'));
	ComponentLibrary = GFx_Library(GetVariableObject("_root.library", class'Arena.GFx_Library'));
	
	Cursor.SetFloat("x", Parent.Cursor.GetFloat("x"));
	Cursor.SetFloat("y", Parent.Cursor.GetFloat("y"));
	
	if (BaseClass != None)
	{
		SpawnNewBase(BaseClass);
		NameLabel.SetText(Base.ArenaWeaponBaseName);
		
		ComponentUI.SetVisible(false);
	}
	else if (ComponentClass != None)
	{
		SpawnNewComponent(ComponentClass);
		NameLabel.SetText(Component.ComponentName);
		
		ComponentStatMod.SetDisplay(Component.StatMod);
		ComponentDescription.SetDisplay(Component);
		
		ComponentLibrary.BuildLibrary(ArenaWeaponBase(Parent.Weapon), Component);
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

function CloseAnimCompleted()
{
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

defaultproperties
{
	MovieInfo=SwfMovie'ArenaUI.WLSubmenu'
	
	WeaponOffset=(X=48, Y=20, Z=64)
	WeaponScale=0.5
	SpinRate=0.15
	
	bCaptureMouseInput=true
}