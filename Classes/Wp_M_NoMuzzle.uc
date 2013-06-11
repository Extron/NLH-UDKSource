/*******************************************************************************
	Wp_M_NoMuzzle

	Creation date: 04/06/2013 05:44
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_M_NoMuzzle extends Wp_Muzzle;

defaultproperties
{
	ComponentName="No Muzzle"
	ComponentDescription="Only the rich or lucky are generally seen with muzzle attachments on their weapons.  This is because muzzle attachments generally offer only advantage on the battlefield, and not having one is not detrimental."
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