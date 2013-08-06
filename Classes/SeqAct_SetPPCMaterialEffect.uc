/*******************************************************************************
	SeqAct_SetPPCMaterialEffect

	Creation date: 18/07/2013 23:47
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class SeqAct_SetPPCMaterialEffect extends SeqAct_SetPostProcessChain;

var() MaterialInterface Material;
var Object ObjectReference;

event Activated()
{
	local array<PostProcessEffect> PostProcessEffects;
	local int i;
	local MaterialEffect MaterialEffect;
	local MaterialInterface MaterialInterface;
	local MaterialInstanceActor MaterialInstanceActor;

	GetPostProcessEffects(PostProcessEffects, class'MaterialEffect');

	if (PostProcessEffects.Length > 0)
	{
		for (i = 0; i < PostProcessEffects.length; ++i)
		{
			MaterialEffect = MaterialEffect(PostProcessEffects[i]);

			if (MaterialEffect != None)
			{
				if (ObjectReference != None)
				{
					MaterialInterface = MaterialInterface(ObjectReference);

					if (MaterialInterface != None)
					{
						MaterialEffect.Material = MaterialInterface;
					}
					else 
					{
						MaterialInstanceActor = MaterialInstanceActor(ObjectReference);

						if (MaterialInstanceActor != None)
							MaterialEffect.Material = MaterialInstanceActor.MatInst;
					}
				}
				else
				{
					MaterialEffect.Material = Material;
				}
			}
		}
	}
}


defaultproperties
{
  ObjName="Set Material Effect Properties"
  ObjCategory="Post Process"

  VariableLinks(0)=(ExpectedType=class'SeqVar_Object',bHidden=true,LinkDesc="Material Object",PropertyName=ObjectReference)
}