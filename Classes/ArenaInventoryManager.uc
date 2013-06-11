/*******************************************************************************
	ArenaInventoryManager

	Creation date: 06/07/2012 01:27
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaInventoryManager extends InventoryManager;


/** The ability we are trying to switch to. */
var ArenaAbility PendingAbility;

/** A cached list of abilities in the inventory manager for easy ability processing. */
var array<ArenaAbility> Abilities;


/**
 * Switches to Previous weapon
 * Network: Client
 */
simulated function PrevAbility()
{
	local ArenaAbility candidate, start, iter;
	local int i;
	
	start = ArenaPawn(Instigator).ActiveAbility;
	
	if (PendingAbility != None )
	{
		start = PendingAbility;
	}

	// Get previous
	for (i = 0; i < Abilities.Length; i++)
	{
		iter = Abilities[i];
		
		if (iter == start)
		{
			break;
		}
		
		if (!iter.IsPassive)
			candidate = iter;
	}

	// if none found, get last
	if (candidate == None)
	{
		for (i = 0; i < Abilities.Length; i++) 
		{
			iter = Abilities[i];
			
			if (!iter.IsPassive)
				candidate = iter;
		}
	}

	// If same weapon, do not change
	if (candidate == ArenaPawn(Instigator).ActiveAbility)
	{
		return;
	}

	SetCurrentAbility(candidate);
}


/**
 * Switches to Next weapon
 * Network: Client
 */
simulated function NextAbility()
{
	local ArenaAbility start, candidate, iter;
	local bool bBreakNext;
	local int i;
	
	`log("NextAbility");
	
	start = ArenaPawn(Instigator).ActiveAbility;
	
	if (PendingAbility != None)
	{
		start = PendingAbility;
	}

	for (i = 0; i < Abilities.Length; i++)
	{
		iter = Abilities[i];
		
		if (bBreakNext || (start == None) && !iter.IsPassive)
		{
			candidate = iter;
			break;
		}
		if (iter == start)
		{
			bBreakNext = true;
		}
	}

	if (candidate == None)
	{
		for (i = 0; i < Abilities.Length; i++)
		{
			iter = Abilities[i];
			
			if (!iter.IsPassive)
				candidate = iter;
				
			break;
		}
	}
	// If same weapon, do not change
	if (candidate == ArenaPawn(Instigator).ActiveAbility)
	{
		return;
	}

	SetCurrentAbility(candidate);
}


/**
 * Set DesiredWeapon as Current (Active) Weapon.
 * Network: LocalPlayer
 *
 * @param	DesiredWeapon, Desired weapon to assign to player
 */
reliable client function SetCurrentAbility(ArenaAbility desired)
{
	`log("Setting current ability to" @ desired);
	
	// Switch to this weapon
	InternalSetCurrentAbility(desired);

	// Tell the server we have changed the pending weapon
	if( Role < Role_Authority )
	{
		ServerSetCurrentAbility(desired);
	}
}

simulated function PrevWeapon()
{
	local ArenaWeapon	CandidateWeapon, StartWeapon, W;

	StartWeapon = ArenaWeapon(Instigator.Weapon);
	if ( PendingWeapon != None )
	{
		StartWeapon = ArenaWeapon(PendingWeapon);
	}

	// Get previous
	ForEach InventoryActors( class'ArenaWeapon', W )
	{
		if ( W == StartWeapon )
		{
			break;
		}
		CandidateWeapon = W;
	}

	// if none found, get last
	if ( CandidateWeapon == None )
	{
		ForEach InventoryActors( class'ArenaWeapon', W )
		{
			CandidateWeapon = W;
		}
	}

	// If same weapon, do not change
	if ( CandidateWeapon == Instigator.Weapon )
	{
		return;
	}

	SetCurrentWeapon(CandidateWeapon);
}

simulated function NextWeapon()
{
	local ArenaWeapon	StartWeapon, CandidateWeapon, W;
	local bool		bBreakNext;

	StartWeapon = ArenaWeapon(Instigator.Weapon);
	
	if( PendingWeapon != None )
	{
		StartWeapon = ArenaWeapon(PendingWeapon);
	}

	ForEach InventoryActors( class'ArenaWeapon', W )
	{
		if( bBreakNext || (StartWeapon == None) )
		{
			CandidateWeapon = W;
			break;
		}
		if( W == StartWeapon )
		{
			bBreakNext = true;
		}
	}

	if( CandidateWeapon == None )
	{
		ForEach InventoryActors( class'ArenaWeapon', W )
		{
			CandidateWeapon = W;
			break;
		}
	}
	// If same weapon, do not change
	if( CandidateWeapon == Instigator.Weapon )
	{
		return;
	}

	SetCurrentWeapon(CandidateWeapon);
}

/**
 * ServerSetCurrentWeapon begins the Putdown sequence on the server.  This function makes
 * the assumption that if TryPutDown succeeded on the client, it will succeed on the server.
 * This function shouldn't be called from anywhere except SetCurrentWeapon
 *
 * Network: Dedicated Server
 */
reliable server function ServerSetCurrentAbility(ArenaAbility desired)
{
	InternalSetCurrentAbility(desired);
}

simulated private function InternalSetCurrentAbility(ArenaAbility desired)
{
	local ArenaAbility prev;

	prev = ArenaPawn(Instigator).ActiveAbility;

	`LogInv("Prev Ability:" @ prev @ "Desired Ability:" @ desired);

	// Make sure we are switching to a new weapon
	// Handle the case where we're selecting again a weapon we've just deselected
	if (prev != None && desired == prev)
	{
		return;
	}

	// Set the new weapon as pending
	PendingAbility = desired;

	// if there is an old weapon handle it first.
	//if (prev != None && prev != desired && !prev.bDeleteMe && !prev.IsInState('Inactive') )
	//{
		// Try to put the weapon down.
		//`LogInv("Try to put down previous ability first.");
		//prev.TryPutdown();
	//}
	//else
	//{
		// We don't have a weapon, force the call to ChangedWeapon
		ChangedAbility();
	//}
}

/**
 * ChangedAbility is called when the current ability is finished being deactivated
 */
simulated function ChangedAbility()
{
	local ArenaAbility old;

	// Save current weapon as old weapon
	old = ArenaPawn(Instigator).ActiveAbility;

	// Make sure we can switch to a null weapon, otherwise, reactivate the current weapon
	`LogInv(`showvar(PendingAbility)@`showvar(bMustHoldWeapon));
	
	//if (PendingAbility == None && bMustHoldWeapon)
	//{
		//if (old != None)
		//{
			//old.Activate();
			//PendingAbility = old;
		//}
	//}

	`LogInv("switch from" @ old @ "to" @ PendingAbility);

	// switch to Pending Weapon
	ArenaPawn(Instigator).ActiveAbility = PendingAbility;

	// Play any Weapon Switch Animations
	//Instigator.PlayWeaponSwitch(old, PendingAbility);

	// If we are going to an actual weapon, activate it.
	if (PendingAbility != None)
	{
		// Setup the Weapon
		PendingAbility.Instigator = Instigator;

		// Make some noise
		if (WorldInfo.Game != None)
		{
			//Instigator.MakeNoise( 0.1, 'ChangedWeapon' );
		}

		// Activate the Weapon
		PendingAbility.Activate();
		PendingAbility = None;
	}

	// Notify of a weapon change
	if (Instigator.Controller != None)
	{
		//Instigator.Controller.NotifyChangedWeapon(old, Instigator.Weapon);
	}
}

simulated function bool AddInventory(Inventory NewItem, optional bool bDoNotActivate)
{
	if (ArenaAbility(NewItem) != None)
	{
		`log("Adding ability to inventory");
		
		if((NewItem != None) && !NewItem.bDeleteMe )
		{
			if (Abilities.Find(ArenaAbility(NewItem)) > 0)
				return false;
				
			Abilities.AddItem(ArenaAbility(NewItem));
			
			NewItem.SetOwner( Instigator );
			NewItem.Instigator = Instigator;
			NewItem.InvManager = Self;
			NewItem.GivenTo(Instigator, bDoNotActivate);

			Instigator.TriggerEventClass(class'SeqEvent_GetInventory', NewItem);
			return true;
		}

		return false;
	}
	else
	{
		return super.AddInventory(NewItem, bDoNotActivate);
	}
}

/*
simulated function Inventory CreateInventory(class<Inventory> newInvClass, optional bool bDoNotActivate)
{
	local Inventory inv;
	
	inv = super.CreateInventory(newInvClass, bDoNotActivate);
	
	if (ArenaAbility(inv) != None)
		Abilities.AddItem(ArenaAbility(inv));
		
	return inv;
}*/

/*
 * Gets the summed weight of all of the weapons in the inventory.
 *
 * @return Returns the total weight of the weapons in the inventory.
 */
function float GetInventoryWeight()
{
	local ArenaWeaponBase iter;
	local float weight;
	
	foreach InventoryActors(class'ArenaWeaponBase', iter)
	{
		weight += iter.GetWeight();
	}
	
	return weight;
}

defaultproperties
{
	PendingFire(0)=0
	PendingFire(1)=0
}