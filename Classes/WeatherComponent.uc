/*******************************************************************************
	WeatherComponent

	Creation date: 25/12/2014 14:23
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

/**
 * A component that can be added to objects to allow them to respond to weather effects.
 */
class WeatherComponent extends ActorComponent;

/**
 * A static overlay mesh that can be used to draw the environment effects onto.
 */
var(Properties) StaticMesh StaticOverlayMesh<DisplayName=Static Overlay Mesh>;

/**
 * A skeletal overlay mesh that can be used to draw the environment effects onto.
 */
var(Properties) SkeletalMesh SkeletalOverlayMesh<DisplayName=Skeletal Overlay Mesh>;

/**
 * The snow material to draw when it is snowing.
 */
var(Properties) MaterialInstanceConstant SnowMaterial;

/**
 * The rain material to draw when it is snowing.
 */
var(Properties) MaterialInstanceConstant RainMaterial;

/**
 * Indicates which mesh type to draw the environment effects on.
 */
var(Properties) bool UseStaticMesh;


/**
 * A reference to the mesh component that is used to draw the weather effects on.
 */
var MeshComponent OverlayMesh;

/**
 * A reference to the overlay layers manager.
 */
var OverlayLayersComponent OverlayLayers;

/**
 * The current snow level on the object that owns this component.
 */
var float SnowLevel;

/**
 * The current rain level on the object that owns this component.
 */
var float RainLevel;


simulated function BeginPlay()
{
	local OverlayLayersComponent iter;
	
	foreach Owner.ComponentList(class'OverlayLayersComponent', iter)
	{
		OverlayLayers = iter;
		break;
	}
	
	if (UseStaticMesh)
	{
		OverlayMesh = new class'StaticMeshComponent';
		StaticMeshComponent(OverlayMesh).SetStaticMesh(StaticOverlayMesh);
	}
	else
	{
		OverlayMesh = new class'SkeletalMeshComponent';
		SkeletalMeshComponent(OverlayMesh).SetSkeletalMesh(SkeletalOverlayMesh);
	}
}

simulated function Tick(float dt)
{
	local WeatherManager wm;

	super.Tick(dt);
	
	if (ArenaGRI(Owner.WorldInfo.GRI) == None)
		return;
	
	if (ArenaGRI(Owner.WorldInfo.GRI).WeatherMgr == None)
		return;
		
	wm = ArenaGRI(Owner.WorldInfo.GRI).WeatherMgr;
	
	if (Owner.FastTrace(Owner.Location + vect(0, 0, 1000)))
	{
		if (wm.Snowing)
			SnowLevel += dt * wm.WeatherIntensity * wm.SnowBuildupRate;
		else if (wm.Thawing)
			SnowLevel -= dt * wm.Temperature * wm.SnowBuildupRate;
		else
			SnowLevel = 0.0;
			
		if (wm.Raining)
			RainLevel += dt * wm.WeatherIntensity * wm.RainBuildupRate;
		
		SnowLevel = FClamp(SnowLevel, 0.0, 1.0);
		RainLevel = FClamp(RainLevel, 0.0, 1.0);
		
		if (SnowLevel > 0)
		{
			OverlayMesh.SetMaterial(0, SnowMaterial);
			SnowMaterial.SetScalarParameterValue('WeatherLevel', SnowLevel > 0 ? SnowLevel : RainLevel);
			
			if (OverlayLayers.FindLayer("WeatherLayer") < 0)
				OverlayLayers.AddLayer("WeatherLayer", OverlayMesh);
		}
		else if (RainLevel > 0)
		{
			OverlayMesh.SetMaterial(0, RainMaterial);
			RainMaterial.SetScalarParameterValue('WeatherLevel', SnowLevel > 0 ? SnowLevel : RainLevel);
			
			if (OverlayLayers.FindLayer("WeatherLayer") < 0)
				OverlayLayers.AddLayer("WeatherLayer", OverlayMesh);
		}
		else
		{
			OverlayLayers.RemoveLayer("WeatherLayer");
		}
	}
}