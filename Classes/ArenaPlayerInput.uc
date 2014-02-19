/*******************************************************************************
	ArenaPlayerInput

	Creation date: 07/07/2012 23:11
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaPlayerInput extends UDKPlayerInput within ArenaPlayerController;

/**
 * This is set when the user is pressing the forward key.
 */
var input byte Forward;


simulated exec function StartFireAbility()
{
	if (ArenaPawn(Pawn) != None)
	{
		ArenaPawn(Pawn).StartFireAbility();
		FiringAbility = true;
		
		if (ArenaPawn(Pawn).ActiveAbility != None && (!ArenaPawn(Pawn).ActiveAbility.CanHold && !ArenaPawn(Pawn).ActiveAbility.CanCharge))
		{
			StopFireAbility();
		}
	}
}

simulated exec function StopFireAbility()
{
	if (FiringAbility && ArenaPawn(Pawn) != None)
	{
		`log("Unfiring ability");
		ArenaPawn(Pawn).StopFireAbility();
		FiringAbility = false;
	}
}

simulated exec function StartSprint()
{
	if (ArenaPawn(Pawn) != None && Forward == 1)
	{
		ArenaPawn(Pawn).StartSprint();
	}
}

simulated exec function StopSprint()
{
	if (ArenaPawn(Pawn) != None)
	{
		ArenaPawn(Pawn).StopSprint();
	}
}

simulated exec function StartDuck()
{
	if (ArenaPawn(Pawn) != None)
	{
		if (bDuck == 0)
		{
			bDuck = 1;
		}
	}
}

simulated exec function StopDuck()
{
	if (ArenaPawn(Pawn) != None)
	{
		if (bDuck == 1)
		{
			bDuck = 0;
		}
	}
}

simulated exec function StartMelee()
{
	`log("Meleeing");
	
	if (ArenaPawn(Pawn) != None)
	{
		ArenaPawn(Pawn).Melee();
	}
}

simulated exec function Reload()
{
	if (ArenaPawn(Pawn) != None)
	{
		ArenaPawn(Pawn).ReloadWeapon();
	}
}

simulated exec function PrevAbility()
{
	if (ArenaPawn(Pawn) != None)
	{
		ArenaInventoryManager(ArenaPawn(Pawn).InvManager).PrevAbility();
	}
}

simulated exec function NextAbility()
{
	if (ArenaPawn(Pawn) != None)
	{
		ArenaInventoryManager(ArenaPawn(Pawn).InvManager).NextAbility();
	}
}

simulated exec function ToggleStock()
{
	if (ArenaWeaponBase(ArenaPawn(Pawn).HeldWeapon) != None)
		ArenaWeaponBase(ArenaPawn(Pawn).HeldWeapon).ToggleComponent(0);
	else if (ArenaWeaponBase(Pawn.Weapon) != None)
		ArenaWeaponBase(Pawn.Weapon).ToggleComponent(0);
}

simulated exec function ToggleBarrel()
{
	if (ArenaWeaponBase(ArenaPawn(Pawn).HeldWeapon) != None)
		ArenaWeaponBase(ArenaPawn(Pawn).HeldWeapon).ToggleComponent(1);
	else if (ArenaWeaponBase(Pawn.Weapon) != None)
		ArenaWeaponBase(Pawn.Weapon).ToggleComponent(1);
}

simulated exec function ToggleMuzzle()
{
	if (ArenaWeaponBase(ArenaPawn(Pawn).HeldWeapon) != None)
		ArenaWeaponBase(ArenaPawn(Pawn).HeldWeapon).ToggleComponent(2);
	else if (ArenaWeaponBase(Pawn.Weapon) != None)
		ArenaWeaponBase(Pawn.Weapon).ToggleComponent(2);
}

simulated exec function ToggleOptics()
{
	if (ArenaWeaponBase(ArenaPawn(Pawn).HeldWeapon) != None)
		ArenaWeaponBase(ArenaPawn(Pawn).HeldWeapon).ToggleComponent(3);
	else if (ArenaWeaponBase(Pawn.Weapon) != None)
		ArenaWeaponBase(Pawn.Weapon).ToggleComponent(3);
}

simulated exec function ToggleUnder()
{
	if (ArenaWeaponBase(ArenaPawn(Pawn).HeldWeapon) != None)
		ArenaWeaponBase(ArenaPawn(Pawn).HeldWeapon).ToggleComponent(4);
	else if (ArenaWeaponBase(Pawn.Weapon) != None)
		ArenaWeaponBase(Pawn.Weapon).ToggleComponent(4);
}

simulated exec function ToggleSide()
{
	if (ArenaWeaponBase(ArenaPawn(Pawn).HeldWeapon) != None)
		ArenaWeaponBase(ArenaPawn(Pawn).HeldWeapon).ToggleComponent(5);
	else if (ArenaWeaponBase(Pawn.Weapon) != None)
		ArenaWeaponBase(Pawn.Weapon).ToggleComponent(5);
}

simulated exec function ActivateArmor(int slot)
{
	local int i;
	
	`log("Attempting to activate armor slot" @ slot);
	
	if (AP_Player(Pawn) != None)
	{
		for (i = 0; i < AP_Player(Pawn).Armor.Length; i++)
		{
			if (AP_Player(Pawn).Armor[i].Slot == slot)
				AP_Player(Pawn).Armor[i].Activate();
		}
	}
}

function AdjustMouseSensitivity(float FOVScale)
{
	if (ArenaPawn(Pawn) != None)
	{
		aMouseX	*= MouseSensitivity * FOVScale * ArenaPawn(Pawn).Stats.GetLookFactor();
		aMouseY	*= MouseSensitivity * FOVScale * ArenaPawn(Pawn).Stats.GetLookFactor();;
	}
	else
	{
		aMouseX	*= MouseSensitivity * FOVScale;
		aMouseY	*= MouseSensitivity * FOVScale;
	}
}