/*******************************************************************************
	CloudDome

	Creation date: 26/12/2012 20:03
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class CloudDome extends DynamicSMActor;

/** A reference to the material that the skydome uses. */
var MaterialInstanceConstant material;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	material = new class'MaterialInstanceConstant';
	material.SetParent(StaticMeshComponent.GetMaterial(0));
	StaticMeshComponent.SetMaterial(0, material);
}

simulated function Tick(float dt)
{
	super.Tick(dt);
	
	//if (ArenaGRI(WorldInfo.GRI) != None)
		//material.SetScalarParameterValue('TimeOfDay', ArenaGRI(WorldInfo.GRI).TimeOfDay);
}