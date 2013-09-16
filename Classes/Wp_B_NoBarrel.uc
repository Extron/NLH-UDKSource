/*******************************************************************************
	Wp_B_NoBarrel

	Creation date: 12/09/2013 22:11
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_B_NoBarrel extends Wp_Barrel;

defaultproperties
{
	ComponentName="No Barrel"
	ComponentDescription="Some weapons do not have support for separate barrels, either from poor design, damage or misplacement, or simply a matter of impracticality."
	CompatibleTypes[0]=WTRifle
	
	CompatibleSizes[3]=WSHand
}