/*******************************************************************************
	DynamicEnvironmentObject

	Creation date: 28/07/2012 22:15
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/* 
 * This class is for objects that are dymanic in the world that are affected by elemental abilities, such as magnetic crates that can be thrown.
 */
class DynamicEnvironmentObject extends UDKKActorBreakable implements(IEnvObj) 
	placeable;

var(Porperties) Array<string> ObjectProperties;

var Array<EnvironmentEffect> ActiveEffects;

simulated function Tick(float delta)
{
	local int i;
	
	for (i = 0; i < ActiveEffects.Length; i++)
	{
		ActiveEffects[i].UpdateEffect(i);
	}
	
	super.Tick(delta);	
}

simulated function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local int i;
	local class<EnvironmentEffect> e;
	local EnvironmentEffect effect;
	
	if (class<AbilityDamageType>(DamageType) != None && ArenaPlayerController(EventInstigator) != None)
	{
		for (i = 0; i < class<AbilityDamageType>(DamageType).Default.EnvironmentEffects.Length; i++)
		{
			e = class<AbilityDamageType>(DamageType).Default.EnvironmentEffects[i];
			
			if (HasProperties(e.Default.Properties))
			{
				effect = spawn(e, Self);
				effect.ActivateEffect(Self, ArenaPlayerController(EventInstigator));
				effect.ChangeState(ActiveEffects);
				
				ActiveEffects.AddItem(effect);
				
				super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
			}
		}
	}
	else
	{
		super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType,  HitInfo, DamageCauser);
	}
} 

/**
 * Gets the environment object's list of properties.
 *
 * @returns Returns the object's property list.
 */
simulated function array<string> GetProperties()
{
	return ObjectProperties;
}

simulated function bool HasProperty(string property)
{
	return ObjectProperties.Find(property) > -1;
}

simulated function bool HasProperties(array<string> properties)
{
	local int i;
	
	for (i = 0; i < properties.Length; i++)
	{
		if (!HasProperty(properties[i]))
			return false;
	}
	
	return true;
}

simulated function bool HasEffect(string effectName)
{
	local int i;
	
	for (i = 0; i < ActiveEffects.Length; i++)
	{
		if (ActiveEffects[i].EffectName == effectName)
			return true;
	}
	
	return false;
}

/**
 * Adds an effect to the environment object.
 *
 * @param effect The effect to add to the object.
 */
simulated function AddEffect(EnvironmentEffect effect)
{
	effect.ChangeState(ActiveEffects);
	
	ActiveEffects.AddItem(effect);
}

/**
 * Removes an effect from the environment object. 
 *
 * @param effect The effect to remove.
 */
simulated function RemoveEffect(EnvironmentEffect effect)
{
	ActiveEffects.RemoveItem(effect);
}

/*
 * This is called when a pawn touches the environment object.
 *
 * pawn - The pawn that touched the object.
 */
simulated function TouchPawn(ArenaPawn pawn)
{
	local int i;
	
	for (i = 0; i < ActiveEffects.Length; i++)
	{
		ActiveEffects[i].AffectPawn(pawn);
	}
}