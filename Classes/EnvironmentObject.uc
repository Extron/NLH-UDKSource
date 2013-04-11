/*******************************************************************************
	EnvironmentObject

	Creation date: 01/07/2012 11:35
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/
/* An environment object is a placable world object that can be affected by elemental abilities */
class EnvironmentObject extends StaticMeshActor implements(IEnvObj)
	placeable;

/* A list of properties that the object has.  These define how elemental abilities affect the object.*/
var(Porperties) Array<string> ObjectProperties;

/**
 * The currently active effect on the object.
 */
var EnvironmentEffect ActiveEffect;

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

simulated function Tick(float delta)
{
	if (ActiveEffect != None)
		ActiveEffect.UpdateEffect(delta);

	if (Material == None)
	{
		Material = new class'MaterialInstanceConstant';
		Material.SetParent(StaticMeshComponent.GetMaterial(0));
		StaticMeshComponent.SetMaterial(0, Material);
	}
	
	if (ArenaGRI(WorldInfo.GRI) != None && ArenaGRI(WorldInfo.GRI).WeatherMgr != None)
	{
		if (FastTrace(Location + vect(0, 0, 1000)))
		{
			if (ArenaGRI(WorldInfo.GRI).WeatherMgr.Snowing)
				SnowLevel += delta * ArenaGRI(WorldInfo.GRI).WeatherMgr.WeatherIntensity * ArenaGRI(WorldInfo.GRI).WeatherMgr.SnowBuildupRate;
			else if (ArenaGRI(WorldInfo.GRI).WeatherMgr.Thawing)
				SnowLevel -= delta * ArenaGRI(WorldInfo.GRI).WeatherMgr.Temperature * ArenaGRI(WorldInfo.GRI).WeatherMgr.SnowBuildupRate;
			
			if (ArenaGRI(WorldInfo.GRI).WeatherMgr.Raining)
				RainLevel += delta * ArenaGRI(WorldInfo.GRI).WeatherMgr.WeatherIntensity * ArenaGRI(WorldInfo.GRI).WeatherMgr.RainBuildupRate;
			else
				RainLevel -= delta * ArenaGRI(WorldInfo.GRI).WeatherMgr.WeatherIntensity * ArenaGRI(WorldInfo.GRI).WeatherMgr.RainBuildupRate;
			
			SnowLevel = FClamp(SnowLevel, 0.0, 1.0);
			RainLevel = FClamp(RainLevel, 0.0, 1.0);
			
			Material.SetScalarParameterValue('WeatherLevel', SnowLevel > 0 ? SnowLevel : RainLevel);
			Material.SetScalarParameterValue('Snow', SnowLevel > 0 ? 1 : 0);
			Material.SetScalarParameterValue('Rain', (!Frozen && RainLevel > 0) ? 1 : 0);
		}
	}
	
	super.Tick(delta);	
}

simulated function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local int i;
	local class<EnvironmentEffect> e;
	local EnvironmentEffect effect;
	
	`log("Hit environment object.");
	
	if (class<AbilityDamageType>(DamageType) != None && ArenaPlayerController(EventInstigator) != None)
	{
		for (i = 0; i < class<AbilityDamageType>(DamageType).Default.EnvironmentEffects.Length; i++)
		{
			e = class<AbilityDamageType>(DamageType).Default.EnvironmentEffects[i];
			
			if (HasProperties(e.Default.Properties))
			{
				effect = spawn(e, Self);
				AddEffect(effect, ArenaPlayerController(EventInstigator));
				
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
	return InStr(ActiveEffect.EffectName, effectName) > -1;
}

/**
 * Adds an effect to the environment object.
 *
 * @param effect The effect to add to the object.
 */
simulated function AddEffect(EnvironmentEffect effect, ArenaPlayerController controller)
{
	local EnvironmentEffect sum;
	
	if (ActiveEffect != None)
	{
		sum = class'Arena.EnvironmentEffect'.static.AddEffects(effect, ActiveEffect);
		RemoveEffect();
		ActiveEffect = sum;
	}
	else
	{
		ActiveEffect = effect;
	}
		
	ActiveEffect.ActivateEffect(Self, controller);
}

/**
 * Removes the currently active effect from the environment object. 
 */
simulated function RemoveEffect()
{
	ActiveEffect.DeactivateEffect();
	ActiveEffect.Destroy();
	ActiveEffect = None;
}

/*
 * This is called when a pawn touches the environment object.
 *
 * pawn - The pawn that touched the object.
 */
simulated function TouchPawn(ArenaPawn pawn)
{
	if (ActiveEffect != None)
		ActiveEffect.AffectPawn(pawn);
}

defaultproperties
{
	bStatic=false
	bMovable=false
}