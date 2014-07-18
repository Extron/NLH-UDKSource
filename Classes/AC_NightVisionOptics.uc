/*******************************************************************************
	AC_NightVisionOptics

	Creation date: 18/02/2014 09:06
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class AC_NightVisionOptics extends ArmorComponent;

var PostProcessChain NVEffect;

event Activate()
{
	local ArenaPlayerController player;
	local int i;
	local int chainIdx;
	
	if (ArenaPawn(Owner) == None)
		return;
	
	player = ArenaPlayerController(ArenaPawn(Owner).Owner);
	
	if (!(LocalPlayer(player.Player) != None && LocalPlayer(player.Player).PlayerPostProcess != None))
		return;
	
	if (!Active)
	{
		LocalPlayer(player.Player).InsertPostProcessingChain(NVEffect, 0, false);
		Active = true;
	}
	else
	{
		chainIdx = -1;
		for (i = 0; i < LocalPlayer(player.Player).PlayerPostProcessChains.Length; i++)
		{
			if (LocalPlayer(player.Player).PlayerPostProcessChains[i].FindPostProcessEffect('NightVisionMat') != None)
			{
				chainIdx = i;
				break;
			}
		}
		
		if (chainIdx > -1)
			LocalPlayer(player.Player).RemovePostProcessingChain(chainIdx);
			
		Active = false;
	}
}

defaultproperties
{
	NVEffect=PostProcessChain'ArenaMaterials.PostProcess.NightVisionPPC'
	Type=ACTEyeImplant
	Slot=1
	
	ComponentName="Night Vision Implant"
}