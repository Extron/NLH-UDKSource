/*******************************************************************************
	SE_Flash

	Creation date: 16/04/2013 14:25
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class SE_Flash extends StatusEffect;


defaultproperties
{
	Begin Object Name=NewStatMod
		ValueMods[PSVMobility]=0.5
		ValueMods[PSVStability]=0.15
		ValueMods[PSVAccuracy]=0.15
	End Object
	
	EffectName="Flashed"
	Duration=1
	Group=EG_Electromagnetism
	ScreenEffect=PostProcessChain'ArenaMaterials.PostProcess.FlashedPPC';
}