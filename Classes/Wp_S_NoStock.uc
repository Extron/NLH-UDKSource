/*******************************************************************************
	Wp_S_NoStock

	Creation date: 04/06/2013 06:17
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_S_NoStock extends Wp_Stock;

defaultproperties
{
	Begin Object Name=NewStatMod
		ValueMods[WSVRecoil]=0.1
		ValueMods[WSVStability]=0.1
		ValueMods[WSVAccuracy]=0.25
		ValueMods[WSVMobility]=2
	End Object
	
	ComponentName="No Stock"
	ComponentDescription="It is common to see a weapon without a stock, either by choice or lack of resources.  Without one, the weapon becomes lighter and more mobile, but its accuracy, recoil, and stability suffer drastically."
	
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
}