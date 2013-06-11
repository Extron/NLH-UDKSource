/*******************************************************************************
	Wp_O_NoOptics

	Creation date: 04/06/2013 05:42
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_O_NoOptics extends Wp_Optics;

defaultproperties
{
	ComponentName="No Optics"
	ComponentDescription="Some weapons do not have support for iron sights, either from poor design, damage or misplacement, or simply a matter of impracticality. Either way, lack of iron sights prevents aim down sights."
	CompatibleTypes[0]=WTRifle
	CompatibleTypes[1]=WTShotgun
	CompatibleTypes[2]=WTHardLightRifle
	CompatibleTypes[3]=WTGrenadeLauncher
	CompatibleTypes[4]=WTRocketLauncher
	CompatibleTypes[5]=WTBeamRifle
	CompatibleTypes[6]=WTPlasmaRifle
	CompatibleTypes[7]=WTRailGun
	
	CompatibleSizes[0]=WSSmall
	CompatibleSizes[1]=WSRegular
	CompatibleSizes[2]=WSLarge
	CompatibleSizes[3]=WSHand
	CompatibleSizes[4]=WSHeavy
}