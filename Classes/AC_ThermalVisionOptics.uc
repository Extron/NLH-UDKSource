/*******************************************************************************
	AC_ThermalVisionOptics

	Creation date: 28/02/2014 21:11
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class AC_ThermalVisionOptics extends ArmorComponent;

var PostProcessChain TVEffect;
var float HeatReadingRange;

event Tick(float dt)
{
	local ArenaPawn iter;
	
	if (Active)
	{
		foreach WorldInfo.AllPawns(class'Arena.ArenaPawn', iter)
		{
			if (iter.CurrentDrawMode != DMThermal)
				iter.EnableThermal();
				
			if (VSize(iter.Location - Owner.Location) > HeatReadingRange)
				iter.SetHidden(true);
			else
				iter.SetHidden(false);
		}
	}
}

event Activate()
{
	local ArenaPlayerController player;
	local ArenaPawn iter;
	local int i;
	local int chainIdx;
	
	if (ArenaPawn(Owner) == None)
		return;
	
	player = ArenaPlayerController(ArenaPawn(Owner).Owner);
	
	if (!(LocalPlayer(player.Player) != None && LocalPlayer(player.Player).PlayerPostProcess != None))
		return;
	
	if (!Active)
	{
		LocalPlayer(player.Player).InsertPostProcessingChain(TVEffect, /*LocalPlayer(player.Player).PlayerPostProcessChains.Length*/0, false);
		Active = true;
		
		foreach WorldInfo.AllPawns(class'Arena.ArenaPawn', iter)
			iter.EnableThermal();
	}
	else
	{
		chainIdx = -1;
		for (i = 0; i < LocalPlayer(player.Player).PlayerPostProcessChains.Length; i++)
		{
			if (LocalPlayer(player.Player).PlayerPostProcessChains[i].FindPostProcessEffect('TVDistort') != None)
			{
				chainIdx = i;
				break;
			}
		}
		
		if (chainIdx > -1)
			LocalPlayer(player.Player).RemovePostProcessingChain(chainIdx);
			
		foreach WorldInfo.AllPawns(class'Arena.ArenaPawn', iter)
		{
			iter.DisableAltAppearance();
			iter.SetHidden(false);
		}
			
		Active = false;
	}
}

defaultproperties
{
	TVEffect=PostProcessChain'ArenaMaterials.PostProcess.ThermalVisionPPC'
	Type=ACTEyeImplant
	Slot=1
	HeatReadingRange=2560
	
	ComponentName="Thermal Visio Implant"
}