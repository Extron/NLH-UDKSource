/*******************************************************************************
	Ab_TremblingEarth

	Creation date: 23/06/2013 02:35
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Ab_TremblingEarth extends Ab_Earthquake;

defaultproperties
{
	VolumeClass=class'Arena.Ab_StunningEarthquakeVolume'
	
	CoolDown=5
	EnergyCost=500
	AbilityName="Trembling Earth"
}