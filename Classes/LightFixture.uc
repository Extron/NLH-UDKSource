/*******************************************************************************
	LightFixture

	Creation date: 28/04/2014 19:15
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

/**
 * Encapsulates all that is needed for a light fixture, including the mesh, the light component, and references to switches the light is bound to.
 */
class LightFixture extends Actor implements(IToggleableObject)
	placeable;

/**
 * The mesh for the fixture.
 */
var(Fixture) MeshComponent Mesh;

/**
 * The light environment for the fixture's mesh.
 */
var(Fixture) DynamicLightEnvironmentComponent LightEnvironment;

/**
 * The light component of the light fixture.
 */
var(Fixture) LightComponent LightComponent;

/**
 * Indicates whether the light is on or not.
 */
var(Fixture) bool On;

/**
 * The emission factor to place on the material when the light is on.
 */
var(Fixture) float Emission;

/**
 * The light's material.
 */
var MaterialInstanceConstant Material;



simulated function PostBeginPlay()
{
	local LinearColor linColor;
	
	super.PostBeginPlay();
	
	Material = new class'MaterialInstanceConstant';
	Material.SetParent(Mesh.GetMaterial(0));
	
	linColor.r = float(LightComponent.LightColor.r) / 255.0;
	linColor.g = float(LightComponent.LightColor.g) / 255.0;
	linColor.b = float(LightComponent.LightColor.b) / 255.0;
	
	Material.SetVectorParameterValue('EmissionTint', linColor);
	
	if (On)
		Material.SetScalarParameterValue('EmissionFactor', Emission);
	else
		Material.SetScalarParameterValue('EmissionFactor', 0);
		
	Mesh.SetMaterial(0, Material);
	
	LightComponent.SetEnabled(On);
}

/**
 * Toggles the light, turning it on or off.
 */
 
simulated function Toggle()
{
	On = !On;
	
	if (On)
		Material.SetScalarParameterValue('EmissionFactor', Emission);
	else
		Material.SetScalarParameterValue('EmissionFactor', 0);
		
	LightComponent.SetEnabled(On);
}

defaultproperties
{
	Begin Object Class=DrawLightRadiusComponent Name=DrawLightRadius
	End Object
	Components.Add(DrawLightRadius)

	Begin Object Class=DrawLightConeComponent Name=DrawInnerCone
		ConeColor=(R=150,G=200,B=255)
	End Object
	Components.Add(DrawInnerCone)

	Begin Object Class=DrawLightConeComponent Name=DrawOuterCone
		ConeColor=(R=200,G=255,B=255)
	End Object
	Components.Add(DrawOuterCone)

	Begin Object Class=DrawLightRadiusComponent Name=DrawLightSourceRadius
		SphereColor=(R=231,G=239,B=0,A=255)
	End Object
	Components.Add(DrawLightSourceRadius)
	
	
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
		bEnabled=TRUE
	End Object
	LightEnvironment=MyLightEnvironment
	Components.Add(MyLightEnvironment)
	
	Begin Object Class=StaticMeshComponent Name=SM
		LightEnvironment=MyLightEnvironment
	End Object
	Mesh=SM
	Components.Add(SM)
	
	Begin Object Class=SpotLightComponent Name=SpotLightComponent
	    LightAffectsClassification=LAC_STATIC_AFFECTING
		CastShadows=true
		CastStaticShadows=true
		CastDynamicShadows=false
		bForceDynamicLight=false
		UseDirectLightMap=true
		LightingChannels=(BSP=true,Static=true,Dynamic=true,bInitialized=true)
	    PreviewLightRadius=DrawLightRadius
		PreviewInnerCone=DrawInnerCone
		PreviewOuterCone=DrawOuterCone
		PreviewLightSourceRadius=DrawLightSourceRadius
	End Object
	LightComponent=SpotLightComponent
	Components.Add(SpotLightComponent)
	
	Emission=25
	On=true
}