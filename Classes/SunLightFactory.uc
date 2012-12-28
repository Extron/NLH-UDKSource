/*******************************************************************************
	SunLightFactory

	Creation date: 23/12/2012 02:16
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class SunLightFactory extends ActorFactoryDominantDirectionalLightMovable;

defaultproperties
{
	MenuName="Add Light (SunLight)"
	NewActorClass=class'Arena.SunLight'
}

