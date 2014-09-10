/*******************************************************************************
	ArenaPointLight

	Creation date: 09/09/2014 00:23
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

/**
 * A toogleable point light that is more dynamic than the default point light.
 */
class ArenaPointLight extends ArenaLightActor
	ClassGroup(Lights,PointLights)
	placeable;

defaultproperties
{
	Begin Object Name=Sprite
		Sprite=Texture2D'EditorResources.LightIcons.Light_Point_Stationary_Statics'
	End Object

	Begin Object Class=DrawLightRadiusComponent Name=DrawLightRadius0
	End Object
	Components.Add(DrawLightRadius0)

	Begin Object Class=DrawLightRadiusComponent Name=DrawLightSourceRadius0
		SphereColor=(R=231,G=239,B=0,A=255)
	End Object
	Components.Add(DrawLightSourceRadius0)

	Begin Object Class=PointLightComponent Name=PointLightComponent0
	    LightAffectsClassification=LAC_STATIC_AFFECTING
		CastShadows=false
		CastStaticShadows=false
		CastDynamicShadows=false
		bForceDynamicLight=true
		UseDirectLightMap=false
		LightingChannels=(BSP=true,Static=true,Dynamic=true,bInitialized=true)
		PreviewLightRadius=DrawLightRadius0
		PreviewLightSourceRadius=DrawLightSourceRadius0
	End Object
	LightComponent=PointLightComponent0
	Components.Add(PointLightComponent0)
}