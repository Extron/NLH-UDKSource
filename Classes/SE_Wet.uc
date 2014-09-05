/*******************************************************************************
	SE_Wet

	Creation date: 25/08/2014 17:57
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class SE_Wet extends StatusEffect;

simulated function ActivateEffect(Actor target)
{
	local MaterialEffect effect;
	
	super.ActivateEffect(target);
	
	if (ArenaPawn(target) != None && PlayerController(ArenaPawn(target).Controller) != None)
	{
		if (LocalPlayer(PlayerController(ArenaPawn(target).Controller).Player) != None && LocalPlayer(PlayerController(ArenaPawn(target).Controller).Player).PlayerPostProcess != None && ScreenEffect != None)
		{
			effect = MaterialEffect(ScreenEffect.FindPostProcessEffect('WetMat'));
			MaterialInstanceTimeVarying(effect.Material).SetDuration(Duration);
		}
	}
}

defaultproperties
{	
	EffectName="Wet"
	Duration=5
	Group=EG_Water
	ScreenEffect=PostProcessChain'ArenaMaterials.PostProcess.WetPPC';
}