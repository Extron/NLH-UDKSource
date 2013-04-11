/*******************************************************************************
	GFx_BasicHUD

	Creation date: 09/03/2013 00:02
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_BasicHUD extends GFxMoviePlayer;

/**
 * The pawn that owns the HUD.
 */
var ArenaPawn Pawn;

var GFxObject WeaponStats, AbilityStats;
var GFxObject WeaponName, WeaponAmmo;
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


function Init(optional LocalPlayer player)
{
	super.Init(player);
	
	//GRI = UTGameReplicationInfo(GetPC().WorldInfo.GRI);
	
	if (ArenaPawn(GetPC().Pawn) != None)
		Pawn = ArenaPawn(GetPC().Pawn);
		
	Start();
    Advance(0);
	
	WeaponStats = GetVariableObject("_root.weapon_stat");
	AbilityStats = GetVariableObject("_root.ability_stat");
	WeaponName = GetVariableObject("_root.weapon_stat.weapon_name");
	WeaponAmmo = GetVariableObject("_root.weapon_stat.weapon_ammo");
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
	
	AngleComponent(HealthStats);
	AngleComponent(WeaponStats);
	AngleComponent(AbilityStats);
}

function UpdateHUD(float dt)
{
	local float nBloom;
	local float xR, xL, yT, yB;
	
	if (Pawn != None)
	{
		if (Pawn.ActiveAbility != None)
		{
			AbilityName.SetText("Ability:" @ Pawn.ActiveAbility.AbilityName);		
		
			if (Pawn.ActiveAbility.CanFire)
			{
				AbilityCoolDown.SetText("Ability ready to fire.");
			}
			else
			{
				AbilityCoolDown.SetText("Cooling Down..." @ Pawn.ActiveAbility.GetRemainingCoolDownTime());
			}
		
		}
		
		if (ArenaWeaponBase(Pawn.Weapon) != None)
		{
			WeaponName.SetText("Weapon:" @ ArenaWeaponBase(Pawn.Weapon).WeaponName);
			WeaponAmmo.SetText("Clip:" @ ArenaWeaponBase(Pawn.Weapon).Clip);
			
			nBloom = ArenaWeaponBase(Pawn.Weapon).Bloom / ArenaWeaponBase(Pawn.Weapon).Stats.Constants.GetStatMax("Bloom");
			xL = -nBloom * ReticuleBloomXMax * NativeWidth * 0.5;
			xR = nBloom * (ReticuleBloomXMax * NativeWidth * 0.5);
			yT = -nBloom * ReticuleBloomYMax * NativeHeight * 0.5;
			yB = nBloom * (ReticuleBloomYMax * NativeHeight * 0.5);
			
			RetTop.SetFloat("y", yT);
			RetBot.SetFloat("y", yB);
			RetLeft.SetFloat("x", xL);
			RetRight.SetFloat("x", xR);
			
		}
		
		if (Pawn.Health < Pawn.HealthMax / 2.0)
			CriticalHealthBackground.SetVisible(true);
		else
			CriticalHealthBackground.SetVisible(false);
			
		if (Pawn.NearestInterObject != None)
			MainMessage.SetText(Pawn.NearestInterObject.GetMessage());
		else
			MainMessage.SetText("");
		
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