/*******************************************************************************
	Ab_ThunderRush

	Creation date: 25/08/2012 19:07
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Ab_ThunderRush extends Ab_ShockShort;

/**
 * The location that the player was at when he was thrust foreward.
 */
var vector ThrustLocation;

/**
 * The distance to the target
 */
var float DistanceToTarget;

/**
 * The animation to play when the player has contacted an enemy or object and is rushing to them.
 */
var name RushAnim;

/**
 * The animation to play while the player is in mid-flight to a target.
 */
var name RushMoveAnim;

/**
 * The animation to play when the player punches an enemy after rushing them.
 */
var name RushPunchAnim;

simulated function ProcessInstantHit(byte mode, ImpactInfo impact, optional int numHits)
{
	local vector vel;
	
	super.ProcessInstantHit(mode, impact, numHits);
	
	`log("Processing hit:  HitActor" @ impact.HitActor);
	
	if (ArenaPawn(impact.HitActor) != None)
	{
		ThrustLocation = Instigator.Location;
		
		vel = Normal(impact.HitLocation - Instigator.Location) * vect(1, 1, 0.15);
		
		if (ArenaPawn(Instigator).Physics != PHYS_Falling)
		{
			ArenaPawn(Instigator).AddVelocity(vel * 5000, vect(0, 0, 0), None);
		}
		else
		{
			ArenaPawn(Instigator).AddVelocity(vel * 1500, vect(0, 0, 0), None);
		}
		
		AP_Player(Instigator).PlayAnimation(RushAnim, 0.0, false, 0.0, 0.0, true);
		AP_Player(Instigator).OnLanded = PlayerLanded;
		SetTimer(GetArmAnimLength(RushAnim), false, 'FireAnimComplete');
	}
}

simulated function LoopAnimation()
{
	AP_Player(Instigator).CurrentAnimationUninterruptable = false;
	AP_Player(Instigator).PlayAnimation(RushMoveAnim, 0.0, true, 0.0, 0.0, true);
}

simulated function PlayerLanded()
{
	AP_Player(Instigator).CurrentAnimationUninterruptable = false;
	AP_Player(Instigator).PlayAnimation(RushPunchAnim, 0.0, false, 0.0, 0.15, true);
	AP_Player(Instigator).OnLanded = None;
}

defaultproperties
{
	RushAnim=ThunderRush
	RushMoveAnim=ThunderRushMove
	RushPunchAnim=ThunderRushHit
	
	AbilityName="Thunder Rush"
	AbilityIcon="ArenaAbilities.Icons.ThunderRush"
}