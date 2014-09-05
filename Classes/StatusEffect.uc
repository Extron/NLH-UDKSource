/*******************************************************************************
	StatusEffect

	Creation date: 08/07/2012 18:43
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/*
 * A status effect is attached to a player to modify certain properties of the player.  
 * For example, players with the electrocuted status effect will suffer some damage, 
 * have slower movement speed, and experience HUD and mod malfunctions.
 */
class StatusEffect extends EntityEffect
	dependson(PlayerStats);

/**
 * The list of display colors to use when showing this status effect.  Length should agree with Combinations variable.
 */
var int DisplayColor;

/**
 * The stat modifier for the status effect. 
 */
var PlayerStatModifier StatsModifier;

/**
 * The damage type class that this status carries. 
 */
var class<StatusDamageType> DamageType;

/** 
 * A reference to the screen effect to use while this effect is active. 
 */
var PostProcessChain ScreenEffect;

/**
 * The points that this status effect gives if a pawn is killed directly by this effect.
 */
var float KilledByPoints;

/**
 * The points that this status effect gives if a pawn had this status effect when they died.
 */
var float KilledWhilePoints;


simulated function ActivateEffect(Actor Target)
{
	super.ActivateEffect(Target);
	
	if (ArenaPawn(Target) == None)
	{
		`warn("Cannot apply a status effect to anything but a pawn.");
		DeactivateEffect();
		return;
	}
	
	ArenaPawn(Target).Stats.AddModifier(StatsModifier);
	
	if (PlayerController(ArenaPawn(Target).Controller) != None)
	{
		if (LocalPlayer(PlayerController(ArenaPawn(Target).Controller).Player) != None && LocalPlayer(PlayerController(ArenaPawn(Target).Controller).Player).PlayerPostProcess != None && ScreenEffect != None)
			LocalPlayer(PlayerController(ArenaPawn(Target).Controller).Player).InsertPostProcessingChain(ScreenEffect, 0, false);
	}
}

simulated function DeactivateEffect()
{
	if (ArenaPawn(Affectee) != None)
	{
		ArenaPawn(Affectee).ActiveEffects.RemoveItem(self);
		
		ArenaPawn(Affectee).Stats.RemoveModifier(StatsModifier);
		
		if (PlayerController(ArenaPawn(Affectee).Controller) != None)
		{
			if (LocalPlayer(PlayerController(ArenaPawn(Affectee).Controller).Player) != None && LocalPlayer(PlayerController(ArenaPawn(Affectee).Controller).Player).PlayerPostProcess != None && ScreenEffect != None)
				LocalPlayer(PlayerController(ArenaPawn(Affectee).Controller).Player).RemovePostProcessingChain(0);
		}
	}
	
	super.DeactivateEffect();
}

defaultproperties
{
	Begin Object Class=PlayerStatModifier Name=NewStatMod
	End Object
	StatsModifier=NewStatMod
	
	DisplayColor=0xFFFFFF
}