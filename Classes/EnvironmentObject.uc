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
var(Properties) Array<string> ObjectProperties;

/**
 * The scaling of the x coordinate of the mesh's UV coordinates.  Use this to tile the texture put onto it.  A value of zero 
 * means that the default material settings will be used.
 */
var(Properties) float MatUVXScale;

/**
 * The scaling of the y coordinate of the mesh's UV coordinates.  Use this to tile the texture put onto it.  A value of zero 
 * means that the default material settings will be used.
 */
var(Properties) float MatUVYScale;

/**
 * The currently active effects on the object.
 */
var array<EnvironmentEffect> ActiveEffects;

/** 
 * A reference to the base material that the actor uses. 
 */
var MaterialInstanceConstant BaseMaterial;

/** 
 * A reference to the snow material that the actor uses. 
 */
var MaterialInstanceConstant SnowMaterial;

/** 
 * A reference to the water material that the actor uses. 
 */
var MaterialInstanceConstant RainMaterial;

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
	local int i;
	
	for (i = 0; i < ActiveEffects.Length; i++)
	{
		if (ActiveEffects[i] == None)
		{
			ActiveEffects.Remove(i, 1);
			i--;
			continue;
		}
		
		ActiveEffects[i].Tick(delta);
	}

	if (BaseMaterial == None)
	{
		LoadMaterials();
	}
	
	if (ArenaGRI(WorldInfo.GRI) != None && ArenaGRI(WorldInfo.GRI).WeatherMgr != None)
	{
		//if (FastTrace(Location + vect(0, 0, 1000)))
		//{
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
			
			if (SnowLevel > 0)
			{
				StaticMeshComponent.SetMaterial(0, SnowMaterial);
				SnowMaterial.SetScalarParameterValue('WeatherLevel', SnowLevel > 0 ? SnowLevel : RainLevel);
			}
			else if (RainLevel > 0)
			{
				StaticMeshComponent.SetMaterial(0, RainMaterial);
				RainMaterial.SetScalarParameterValue('WeatherLevel', SnowLevel > 0 ? SnowLevel : RainLevel);
			}
			else
			{
				StaticMeshComponent.SetMaterial(0, BaseMaterial);
			}
		//}
	}
	
	super.Tick(delta);	
}

simulated function TakeDamage(int DamageAmount, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local int i;
	local class<EnvironmentEffect> effectClass;
	local EnvironmentEffect effect;
	
	`log("Hit environment object.");
	
	if (class<ElementDamageType>(DamageType) != None && ArenaPlayerController(EventInstigator) != None)
	{
		for (i = 0; i < ActiveEffects.Length; i++)
		{
			ActiveEffects[i].Explode(class<ElementDamageType>(DamageType));
		}
		
		for (i = 0; i < class<ElementDamageType>(DamageType).Default.EntityEffects.Length; i++)
		{
			if (class<EnvironmentEffect>(class<ElementDamageType>(DamageType).Default.EntityEffects[i]) != None)
			{
				effectClass = class<EnvironmentEffect>(class<ElementDamageType>(DamageType).Default.EntityEffects[i]);
				
				if (HasProperties(effectClass.Default.Properties))
				{
					effect = spawn(effectClass, Self);
					effect.Instigator = EventInstigator.Pawn;
					AddEffect(effect);
					
					super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
				}
			}
		}
	}
	else
	{
		super.TakeDamage(DamageAmount, EventInstigator, HitLocation, Momentum, DamageType,  HitInfo, DamageCauser);
	}
}

simulated function LoadMaterials()
{
	local Texture Diffuse, Normal, Specular, Height;
	local float UVx, UVy, RainUVx, RainUVy, SnowUVx, SnowUVy, SpecularStrength, LightGradient;
	
	BaseMaterial = new class'MaterialInstanceConstant';
	BaseMaterial.SetParent(StaticMeshComponent.GetMaterial(0));
	
	BaseMaterial.GetTextureParameterValue('Diffuse', Diffuse);
	BaseMaterial.GetTextureParameterValue('NormalMap', Normal);
	BaseMaterial.GetTextureParameterValue('Specular', Specular);
	BaseMaterial.GetTextureParameterValue('Heightmap', Height);
	BaseMaterial.GetScalarParameterValue('UVXScale', UVx);
	BaseMaterial.GetScalarParameterValue('UVYScale', UVy);
	BaseMaterial.GetScalarParameterValue('RainUVXScale', RainUVx);
	BaseMaterial.GetScalarParameterValue('RainUVYScale', RainUVy);
	BaseMaterial.GetScalarParameterValue('SnowUVXScale', SnowUVx);
	BaseMaterial.GetScalarParameterValue('SnowUVYScale', SnowUVy);
	BaseMaterial.GetScalarParameterValue('SpecularStrength', SpecularStrength);
	BaseMaterial.GetScalarParameterValue('LightGradient', LightGradient);
	
	if (MatUVXScale != 0)
	{
		UVx = MatUVXScale;
		BaseMaterial.SetScalarParameterValue('UVXScale', UVx);
	}
	
	if (MatUVYScale != 0)
	{
		UVy = MatUVYScale;
		BaseMaterial.SetScalarParameterValue('UVYScale', UVy);
	}
	
	SnowMaterial = new class'MaterialInstanceConstant';
	SnowMaterial.SetParent(Material'ArenaMaterials.Materials.SnowMat');
	SnowMaterial.SetTextureParameterValue('Diffuse', Diffuse);
	SnowMaterial.SetTextureParameterValue('NormalMap', Normal);
	SnowMaterial.SetTextureParameterValue('Specular', Specular);
	SnowMaterial.SetTextureParameterValue('Heightmap', Height);	
	SnowMaterial.SetScalarParameterValue('UVXScale', UVx);
	SnowMaterial.SetScalarParameterValue('UVYScale', UVy);
	SnowMaterial.SetScalarParameterValue('RainUVXScale', RainUVx);
	SnowMaterial.SetScalarParameterValue('RainUVYScale', RainUVy);
	SnowMaterial.SetScalarParameterValue('SnowUVXScale', SnowUVx);
	SnowMaterial.SetScalarParameterValue('SnowUVYScale', SnowUVy);
	SnowMaterial.SetScalarParameterValue('SpecularStrength', SpecularStrength);
	SnowMaterial.SetScalarParameterValue('LightGradient', LightGradient);
	
	RainMaterial = new class'MaterialInstanceConstant';
	RainMaterial.SetParent(Material'ArenaMaterials.Materials.RainMat');
	RainMaterial.SetTextureParameterValue('Diffuse', Diffuse);
	RainMaterial.SetTextureParameterValue('NormalMap', Normal);
	RainMaterial.SetTextureParameterValue('Specular', Specular);
	RainMaterial.SetTextureParameterValue('Heightmap', Height);
	RainMaterial.SetScalarParameterValue('UVXScale', UVx);
	RainMaterial.SetScalarParameterValue('UVYScale', UVy);
	RainMaterial.SetScalarParameterValue('RainUVXScale', RainUVx);
	RainMaterial.SetScalarParameterValue('RainUVYScale', RainUVy);
	RainMaterial.SetScalarParameterValue('SnowUVXScale', SnowUVx);
	RainMaterial.SetScalarParameterValue('SnowUVYScale', SnowUVy);
	RainMaterial.SetScalarParameterValue('SpecularStrength', SpecularStrength);
	RainMaterial.SetScalarParameterValue('LightGradient', LightGradient);
	
	StaticMeshComponent.SetMaterial(0, BaseMaterial);
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
	local PhysicalMaterial mat;
	
	mat = StaticMeshComponent.GetMaterial(0).GetPhysicalMaterial();
	
	if (mat != None && ArenaPMP(mat.PhysicalMaterialProperty) != None)
		return ObjectProperties.Find(property) > -1 || ArenaPMP(mat.PhysicalMaterialProperty).HasProperty(property);
	else
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

simulated function EnvironmentEffect FindEffect(name effectClass)
{
	local int i;
	
	for (i = 0; i < ActiveEffects.Length; i++)
	{
		if (ActiveEffects[i].IsA(effectClass))
			return ActiveEffects[i];
	}

	return None;
}

/**
 * Adds an effect to the environment object.
 */
simulated function AddEffect(EnvironmentEffect effect)
{
	ActiveEffects.AddItem(effect);
	effect.ActivateEffect(self);
}

/**
 * Removes an active effect from the environment object. 
 */
simulated function RemoveEffect(EnvironmentEffect effect)
{
	ActiveEffects.RemoveItem(effect);
}

/**
 * Clears an active effect from the environment object. 
 */
simulated function ClearEffect(EnvironmentEffect effect)
{
	effect.DeactivateEffect();
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
		ActiveEffects[i].AffectTarget(pawn);
}

defaultproperties
{
	bStatic=false
	bMovable=false
}