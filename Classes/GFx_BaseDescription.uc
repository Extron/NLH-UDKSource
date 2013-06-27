/*******************************************************************************
	GFx_BaseDescription

	Creation date: 11/06/2013 03:53
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_BaseDescription extends GFxObject;

function SetDescription(string desc)
{
	ActionScriptVoid("SetDescription");
}

function SetDisplay(ArenaWeaponBase base)
{
	local GFxObject modObj;
	
	modObj = CreateObject("Object");
	
	modObj.SetFloat("Energy", base.EnergyMax);
	modObj.SetString("Type", GetTypeString(base.Type));
	modObj.SetString("Size", GetSizeString(base.Size));
	modObj.SetString("FireModes", GetFireModeString(base, base.AllowedFireModes));
	modObj.SetInt("ClipSize", base.MaxClip);
	modObj.SetFloat("ReloadSpeed", base.GetAvgReloadSpeed());
	modObj.SetFloat("EquipSpeed", base.GetAvgEquipSpeed());
	
	SetDescription(base.BaseDescription);
	
	SetStat(modObj);
}

function SetStat(GFxObject modObj)
{
	ActionScriptVoid("SetStat");
}

function string GetTypeString(WeaponType type)
{
	switch (type)
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
}

function string GetSizeString(WeaponSize size)
{
	switch (size)
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
}

function string GetFireModeString(ArenaWeaponBase base, array<FireMode> modes)
{
	local string s;
	local int i;
	
	s = "";
	
	for (i = 0; i < modes.Length; i++)
	{
		switch (modes[i])
		{
		case FMBoltAction:
			s $= "Bolt";
			break;
			
		case FMSemiAuto:
			s $= "Semi";
			break;
			
		case FMBurst:
			s $= "Burst";
			break;
			
		case FMFullAuto:
			s $= "Full";
			break;
			
		case FMBeam:
			s $= "Beam";
			break;
		}
		
		if (i < modes.Length - 1)
			s $= ", ";
	}
	
	return s;
}