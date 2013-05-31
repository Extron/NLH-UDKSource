/*******************************************************************************
	GFx_BasicHUD

	Creation date: 09/03/2013 00:02
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_BasicHUD extends GFxMoviePlayer;

/**
 * The settings used to configure the HUD display.
 */
var PlayerHUDSettings Settings;

var GFxObject WeaponStats, AbilityStats;
var GFxObject WeaponName, WeaponAmmoNumeric;
var GFxObject AbilityName, AbilityCoolDown;
var GFxObject Reticule;
var GFxObject RetTop, RetBot, RetLeft, RetRight;
var GFxObject HealthStats;
var GFxObject HeadIcon, BodyIcon, LeftArmIcon, RightArmIcon, LeftLegIcon, RightLegIcon;
var GFxObject CriticalHealthBackground;
var GFxObject MainMessage;

/**
 * To help simulate the 3D aspect of the HUD, use 3D rotation to angle the elements of the HUD.  This angle
 * represents the maximum angle in the Y direction (increases as the element progresses along the x axis).
 */
var float AngleYMax;

/**
 * To help simulate the 3D aspect of the HUD, use 3D rotation to angle the elements of the HUD.  This angle
 * represents the maximum angle in the X direction (increases as the element progresses along the y axis).
 */
var float AngleXMax;

/**
 * The native width of the stage of the HUD flash movie.
 */
var float NativeWidth;

/**
 * The native width of the stage of the HUD flash movie.
 */
var float NativeHeight;

/**
 * The maximum distance that the reticule is allowed to travel in the x direction, as a percent (0.0 - 1.0).
 */
var float ReticuleBloomXMax;

/**
 * The maximum distance that the reticule is allowed to travel in the x direction, as a percent (0.0 - 1.0).
 */
var float ReticuleBloomYMax;

/**
 * Indicates that all components of the HUD are hidden.
 */
var bool Hidden;

function Init(optional LocalPlayer player)
{	
	super.Init(player);
	
	//GRI = UTGameReplicationInfo(GetPC().WorldInfo.GRI);
	
	if (ArenaPlayerController(GetPC()) != None)
		Settings = ArenaPlayerController(GetPC()).HUDSettings;
	
	Start();
    Advance(0);
	
	WeaponStats = GetVariableObject("_root.weapon_stat");
	AbilityStats = GetVariableObject("_root.ability_stat");
	WeaponName = GetVariableObject("_root.weapon_stat.weapon_name");
	WeaponAmmoNumeric = GetVariableObject("_root.weapon_stat.weapon_ammo_numeric");
	AbilityName = GetVariableObject("_root.ability_stat.ability_name");
	AbilityCoolDown = GetVariableObject("_root.ability_stat.ability_cooldown");
	Reticule = GetVariableObject("_root.reticule");
	RetTop = GetVariableObject("_root.reticule.tick_top");
	RetBot = GetVariableObject("_root.reticule.tick_bottom");
	RetLeft = GetVariableObject("_root.reticule.tick_left");
	RetRight = GetVariableObject("_root.reticule.tick_right");
	HealthStats = GetVariableObject("_root.health_stats");
	HeadIcon = GetVariableObject("_root.health_stats.body_stats.head_icon");
	BodyIcon = GetVariableObject("_root.health_stats.body_stats.body_icon");
	LeftArmIcon = GetVariableObject("_root.health_stats.body_stats.left_arm_icon");
	RightArmIcon = GetVariableObject("_root.health_stats.body_stats.right_arm_icon");
	LeftLegIcon = GetVariableObject("_root.health_stats.body_stats.left_leg_icon");
	RightLegIcon = GetVariableObject("_root.health_stats.body_stats.right_leg_icon");
	CriticalHealthBackground = GetVariableObject("_root.health_stats.critical_background");
	MainMessage = GetVariableObject("_root.hud_main_message.hud_message");
	
	CriticalHealthBackground.SetVisible(false);
	MainMessage.SetText("");
	
	`log("Weapon stat x" @ WeaponStats.GetFloat("x"));
	AngleComponent(HealthStats);
	AngleComponent(WeaponStats);
	AngleComponent(AbilityStats);
	
	if (Settings != None && !Settings.NumericAmmoDisplay)
		WeaponAmmoNumeric.SetVisible(false);
}

function UpdateHUD(float dt)
{
	local ArenaPawn pawn;
	local float nBloom;
	local float xR, xL, yT, yB;
	
	if (Hidden)
		return;
		
	if (ArenaPawn(GetPC().Pawn) != None)
		pawn = ArenaPawn(GetPC().Pawn);
		
	if (pawn != None && pawn.Health > 0)
	{
		if (pawn.ActiveAbility != None)
		{
			AbilityName.SetText("Ability:" @ pawn.ActiveAbility.AbilityName);		
		
			if (pawn.ActiveAbility.CanFire || pawn.ActiveAbility.IsHolding || pawn.ActiveAbility.IsCharging)
			{
				AbilityCoolDown.SetText("Ability ready to fire.");
			}
			else
			{
				AbilityCoolDown.SetText("Cooling Down..." @ pawn.ActiveAbility.GetRemainingCoolDownTime());
			}
		
		}
		
		if (ArenaWeaponBase(pawn.Weapon) != None)
		{
			WeaponName.SetText("Weapon:" @ ArenaWeaponBase(pawn.Weapon).WeaponName);
			WeaponAmmoNumeric.SetText(ArenaWeaponBase(pawn.Weapon).Clip @ " | " @ (ArenaWeaponBase(pawn.Weapon).Ammo / ArenaWeaponBase(pawn.Weapon).MaxClip));
			
			nBloom = ArenaWeaponBase(pawn.Weapon).Bloom / ArenaWeaponBase(pawn.Weapon).Stats.Constants.GetStatMax("Bloom");
			xL = -nBloom * ReticuleBloomXMax * NativeWidth * 0.5;
			xR = nBloom * (ReticuleBloomXMax * NativeWidth * 0.5);
			yT = -nBloom * ReticuleBloomYMax * NativeHeight * 0.5;
			yB = nBloom * (ReticuleBloomYMax * NativeHeight * 0.5);
			
			RetTop.SetFloat("y", yT);
			RetBot.SetFloat("y", yB);
			RetLeft.SetFloat("x", xL);
			RetRight.SetFloat("x", xR);
			
		}
		
		if (pawn.Health < pawn.HealthMax / 2.0)
			CriticalHealthBackground.SetVisible(true);
		else
			CriticalHealthBackground.SetVisible(false);
			
		if (pawn.NearestInterObject != None)
			MainMessage.SetText(pawn.NearestInterObject.GetMessage());
		else
			MainMessage.SetText("");

		Reticule.SetVisible(!pawn.ADS && !ArenaPlayerController(pawn.Owner).Aiming);
		/*
		Canvas.SetPos(Canvas.ClipX * 0.75, Canvas.ClipY * 0.8);

		Canvas.SetPos(Canvas.ClipX * 0.75, Canvas.ClipY * 0.85);
		Canvas.DrawText("Health:" @ pc.Pawn.Health);
		Canvas.SetPos(Canvas.ClipX * 0.75, Canvas.ClipY * 0.9);
		Canvas.DrawText("Energy:" @ ArenaPawn(pc.Pawn).Energy);*/
	}
}

function AngleComponent(GFxObject component)
{
	local float posX, posY, aX, aY;
	
	posX = component.GetFloat("x");
	posY = component.GetFloat("y");

	aY = (8 * AngleYMax / (NativeWidth ** 3)) * (posX - NativeWidth / 2.0) ** 3;
	aX = -(8 * AngleXMax / (NativeHeight ** 3)) * (posY - NativeHeight / 2.0) ** 3;
	component.SetFloat("rotationY", aY);
	component.SetFloat("rotationX", aX);
}

function HideAllComponents()
{
	WeaponStats.SetVisible(false);
	AbilityStats.SetVisible(false);
	Reticule.SetVisible(false);
	HealthStats.SetVisible(false);
	MainMessage.SetVisible(false);
	Hidden = true;
}

function UnhideAllComponents()
{
	WeaponStats.SetVisible(true);
	AbilityStats.SetVisible(true);
	Reticule.SetVisible(true);
	HealthStats.SetVisible(true);
	MainMessage.SetVisible(true);
	Hidden = false;
}

defaultproperties
{
	MovieInfo=SwfMovie'ArenaUI.BasicHUD'
	
	bAllowInput=FALSE;
	bAllowFocus=FALSE;
	
	NativeWidth=1600
	NativeHeight=900
	AngleYMax=15
	AngleXMax=10
	ReticuleBloomXMax=0.5
	ReticuleBloomYMax=0.5
}