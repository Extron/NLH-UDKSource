/*******************************************************************************
	SeqAct_TogglePPCEffect

	Creation date: 18/07/2013 23:54
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class SeqAct_TogglePPCEffect extends SeqAct_SetPostProcessChain;

var bool Value;

event Activated()
{
	local array<PostProcessEffect> PostProcessEffects;
	local int i;

	if (InputLinks[0].bHasImpulse)
		Value = true;
	else if (InputLinks[1].bHasImpulse)
		Value = false;
	else if (InputLinks[2].bHasImpulse)
		Value = !Value;

	GetPostProcessEffects(PostProcessEffects);

	if (PostProcessEffects.Length > 0)
	{
		for (i = 0; i < PostProcessEffects.length; ++i)
		{
			if (PostProcessEffects[i] != None)
			{
				PostProcessEffects[i].bShowInEditor = Value;
				PostProcessEffects[i].bShowInGame = Value;
			}
		}
	}
}

defaultproperties
{
	ObjName="Toggle Post Process Effects"
	ObjCategory="Post Process"

	InputLinks(0)=(LinkDesc="Enable")
	InputLinks(1)=(LinkDesc="Disable")
	InputLinks(2)=(LinkDesc="Toggle")

	VariableLinks(0)=(ExpectedType=class'SeqVar_Bool',LinkDesc="Bool",bWriteable=true,MinVars=0,PropertyName=Value)
}