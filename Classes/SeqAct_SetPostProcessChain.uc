/*******************************************************************************
	SeqAct_SetPostProcessChain

	Creation date: 18/07/2013 23:48
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class SeqAct_SetPostProcessChain extends SequenceAction abstract;

var() Name PostProcessEffectName;

function GetPostProcessEffects(out array<PostProcessEffect> PostProcessEffects, optional class<PostProcessEffect> MatchingPostProcessEffectClass = class'PostProcessEffect')
{
	local WorldInfo WorldInfo;
	local PostProcessEffect PostProcessEffect;
	local PlayerController PlayerController;
	local LocalPlayer LocalPlayer;

	WorldInfo = class'WorldInfo'.static.GetWorldInfo();

	// Affect the world post process chain
	if (WorldInfo != None)
	{
		foreach WorldInfo.AllControllers(class'PlayerController', PlayerController)
		{
			LocalPlayer = LocalPlayer(PlayerController.Player);

			if (LocalPlayer != None && LocalPlayer.PlayerPostProcess != None)
			{	
				PostProcessEffect = LocalPlayer.PlayerPostProcess.FindPostProcessEffect(PostProcessEffectName);

				if (PostProcessEffect != None && (PostProcessEffect.Class == MatchingPostProcessEffectClass || ClassIsChildOf(PostProcessEffect.Class, MatchingPostProcessEffectClass)))
					PostProcessEffects.AddItem(PostProcessEffect);
			}
		}
	}
}

defaultproperties
{
}