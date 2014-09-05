/*******************************************************************************
	SE_Blind

	Creation date: 14/05/2013 07:18
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * The status effect caused by Sand and its derivatives that blinds foes with sand.
 */
class SE_Blind extends StatusEffect;

defaultproperties
{
	Begin Object Name=NewStatMod
		ValueMods[PSVMobility]=0.5
		ValueMods[PSVStability]=0.15
		ValueMods[PSVAccuracy]=0.15
	End Object
	
	EffectName="Blinded"
	Duration=5
	Group=EG_Earth
	ScreenEffect=PostProcessChain'ArenaMaterials.PostProcess.BlindedPPC';
}