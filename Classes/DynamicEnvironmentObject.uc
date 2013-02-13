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

/** A reference to the material that the actor uses. */
var MaterialInstanceConstant Material;

/**
 * Stores the level of the snow on the object, which increases when it snows and decreases when it is hot.
 */
var float SnowLevel;

/**
 * Stores the level of rain water on the object, which increases when it rains, decreases when it is hot, 
 * and becomes ice when it is cold.
 */
var float RainLevel;

/**
 * Indicates that the object should be frozen.
 */
var bool Frozen;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	Material = new class'MaterialInstanceConstant';
	Material.SetParent(StaticMeshComponent.GetMaterial(0));
	StaticMeshComponent.SetMaterial(0, Material);
}

simulated function Tick(float delta)
{
	local int i;
	
	for (i = 0; i < ActiveEffects.Length; i++)
	{
		ActiveEffects[i].UpdateEffect(i);
	}
	
	if (ArenaGRI(WorldInfo.GRI) != None)
	{
		if (ArenaGRI(WorldInfo.GRI).WeatherMgr.Snowing)
			SnowLevel += delta * ArenaGRI(WorldInfo.GRI).WeatherMgr.WeatherIntensity * ArenaGRI(WorldInfo.GRI).WeatherMgr.SnowBuildupRate;
		else if (ArenaGRI(WorldInfo.GRI).WeatherMgr.Thawing)
			SnowLevel -= delta * ArenaGRI(WorldInfo.GRI).WeatherMgr.Temperature * ArenaGRI(WorldInfo.GRI).WeatherMgr.SnowBuildupRate;
		else if (ArenaGRI(WorldInfo.GRI).WeatherMgr.Raining)
			RainLevel += delta * ArenaGRI(WorldInfo.GRI).WeatherMgr.WeatherIntensity * ArenaGRI(WorldInfo.GRI).WeatherMgr.SnowBuildupRate;
		
		SnowLevel = FClamp(SnowLevel, 0.0, 1.0);
		RainLevel = FClamp(RainLevel, 0.0, 1.0);
		
		Material.SetScalarParameterValue('WeatherLevel', SnowLevel > 0 ? SnowLevel : RainLevel);
		Material.SetScalarParameterValue('Snow', SnowLevel > 0 ? 1 : 0);
		Material.SetScalarParameterValue('Rain', (RainLevel > 0 && !Frozen) ? 1 : 0);
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
simulated function AddEffect(EnvironmentEffect effect, ArenaPlayerController controller)
{
	effect.ActivateEffect(Self, controller);
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