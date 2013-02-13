/*******************************************************************************
	ArenaPlayerInput

	Creation date: 07/07/2012 23:11
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaPlayerInput extends UDKPlayerInput within ArenaPlayerController;

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
	if (ArenaPawn(Pawn) != None)
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