/******************************************************************************
	Ab_RockWall
	
	Creation date: 13/02/2013 14:08
	Copyright (c) 2013, Zack Diller
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
******************************************************************************/

class Ab_RockWall extends ArenaAbility;

/* The pedestal that the ability generates. */
var Ab_RockWallBoulder Wall;

/* The float that determines how far in the ground the pedestal starts */
var float StartDepth;

/* The float that determines how far away from the player the boulder spawns if
	called instantly.*/
var float MinWallDistance;

/* How much further away the wall will spawn per DeltaTime of charging up */
var float ChargeDistance;

/* How high and low the SummonWall function will check for surface before giving up */
var float CheckHeight;

simulated function StopFire(byte FireModeNum)
{
	// Don't fire twice for max charged shots
	if (ChargedHasFired) return;

	`log((ChargeTime * ChargeDistance) + MinWallDistance);
	SummonWall((ChargeTime * ChargeDistance) + MinWallDistance);
	
	super.StopFire(FireModeNum);
}

simulated function SummonWall(float Dist)
{
	// So that it spawns in front of the player
	local float rotSin;
	local float rotCos;
	
	// How far down the wall must spawn to be at the correct height
	local vector checkDepthTop;
	local vector checkDepthBot;
	
	// The current loop iteration
	local int u;
	// The number of loop iterations
	local int CheckTimes;
	
	// 0 if looking in x direction
	rotSin = Sin(Instigator.Rotation.Yaw / (10430.3783505));
	// 1 if looking in y direction
	rotCos = Cos(Instigator.Rotation.Yaw / (10430.3783505));
	
	//`log("Spawning rock wall");
	//`log(Dist);
	
	checkDepthTop = Instigator.Location +
			(vect(0, 1, 0) * Dist * rotSin) +
			(vect(1, 0, 0) * Dist * rotCos) +
			(vect(0, 0, 1) * CheckHeight);
	checkDepthBot = checkDepthTop + vect(0, 0, -10);
	
	// Divide by 5, not 10, so that it keeps going down instead of stopping as user level
	CheckTimes = (CheckHeight / 5);
	
	// Try casting the rock wall on top of the center cubes or somewhere below you (jump & cast): always same height!
	for (u = 0; u < CheckTimes; ++u) {
		if (!FastTrace(checkDepthBot, checkDepthTop)) {
			// TODO: Fix rock wall height after spawning (we do not want + vect(0, 0, 100);)
			Wall = Spawn(class 'Arena.Ab_RockWallBoulder', None, , checkDepthBot + (vect(0, 0, -1) * StartDepth) + vect(0, 0, 90));
			u = CheckTimes + 9;
		}
		else {
			checkDepthTop = checkDepthBot;
			checkDepthBot += vect(0, 0, -10);
		}
	}
	
	// This idicates that the wall was never spawned, the user shall get a refund
	if (u == CheckTimes) {
		`log("The rock could not find a surface to spawn on.");
		RefundAmmo(0.4);
	}
}

defaultproperties
{
	WeaponFireTypes(0)=EWFT_Custom
	
	CoolDown=10
	EnergyCost=78
	AbilityName="Rock Wall"
	
	CanHold = false
	IsPassive = false
	CanCharge = true
	
	StartDepth = 265.0
	MinWallDistance = 460.0
	ChargeDistance = 191.2
	CheckHeight = 700.0

	// Charge-up abilities
	MinCharge = 0.0
	MaxCharge = 3.0
}
