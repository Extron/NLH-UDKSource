/*******************************************************************************
	DynamicEnvironmentObject

	Creation date: 28/07/2012 22:15
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/* 
 * This class is for objects that are dymanic in the world that are affected by elemental abilities, such as magnetic crates that can be thrown.
 */
class DynamicEnvironmentObject extends UDKKActorBreakable placeable;

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
	local int j;
	local class<EnvironmentEffect> e;
	local EnvironmentEffect effect;
	local string p;
	local bool spawnEffect;
	
	`log("Taking damage");
	
	if (class<AbilityDamageType>(DamageType) != None && ArenaPlayerController(EventInstigator) != None)
	{
		for (i = 0; i < class<AbilityDamageType>(DamageType).Default.EnvironmentEffects.Length; i++)
		{
			spawnEffect = true;
			
			e = class<AbilityDamageType>(DamageType).Default.EnvironmentEffects[i];
			
			for (j = 0; j < e.Default.Properties.Length; j++)
			{
				p = e.Default.Properties[j];
				 
				if (ObjectProperties.Find(p) == -1)
				{
					spawnEffect = false;
				}
			}
			
			if (spawnEffect)
			{
				effect = spawn(e, Self);
				effect.ActivateEffect(Self, ArenaPlayerController(EventInstigator));
				ActiveEffects.AddItem(effect);
			}
		}
		
		`log("Take Damage Super called.");
		super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType,  HitInfo, DamageCauser);
	}
} 