/*******************************************************************************
	LightningLight

	Creation date: 15/02/2013 22:42
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class LightningLight extends PointLight;

/**
 * A counter to keep track of time.
 */
var float Counter;

/**
 * The cunnert interval to count up to.
 */
var float Interval;

/**
 * Indicates that the light is on.
 */
var bool On;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	Interval = FRand() * 0.25;
	On = true;
	LightComponent.SetEnabled(On);
}

simulated function Tick(float dt)
{
	super.Tick(dt);
	
	Counter += dt;
	
	if (Counter >= Interval)
	{
		Interval = FRand() * 0.25;
		On = !On;
		
		LightComponent.SetEnabled(On);
		Counter = 0;
	}
}

defaultproperties
{
	Begin Object Name=PointLightComponent0
	    LightAffectsClassification=LAC_DYNAMIC_AND_STATIC_AFFECTING
		CastShadows=TRUE
		CastStaticShadows=TRUE
		CastDynamicShadows=TRUE
		bForceDynamicLight=FALSE
		UseDirectLightMap=false
		LightingChannels=(BSP=TRUE,Static=TRUE,Dynamic=TRUE,bInitialized=TRUE)
		Radius=50000
		Brightness=20
		LightColor=(R=156,G=156,B=255)
	End Object
	
	bStatic=false
	bNoDelete=false
}