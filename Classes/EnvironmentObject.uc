/*******************************************************************************
	EnvironmentObject

	Creation date: 01/07/2012 11:35
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/
/* An environment object is a placable world object that can be affected by elemental abilities */
class EnvironmentObject extends StaticMeshActor placeable;

/* A list of properties that the object has.  These define how elemental abilities affect the object.*/
var(Porperties) Array<string> ObjectProperties;

var Array<EnvironmentEffect> ActiveEffects;

simulated function Tick(float delta)
{
	local int i;
	
	for (i = 0; i < ActiveEffects.Length; i++)
	{
		ActiveEffects[i].UpdateEffect(delta);
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
	}
	
	super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType,  HitInfo, DamageCauser);
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