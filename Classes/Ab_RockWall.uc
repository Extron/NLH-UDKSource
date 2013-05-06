/******************************************************************************
	Ab_RockWall
	
	Creation date: 13/02/2013 14:08
	Copyright (c) 2013, Zack Diller
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
******************************************************************************/

class Ab_RockWall extends ArenaAbility;

/* The pedestal that the ability generates. */
var Ab_RockWallBoulder Wall;

/**
 * The range of the ability.  This is mainly used to determine how high the player can be above the
 * ground and still summon the wall.
 */
var float Range;

/**
 * The height of the rock wall to use when checking bounds.
 */
var float Height;

/* The float that determines how far in the ground the pedestal starts */
var float StartDepth;

/* The float that determines how far away from the player the boulder spawns if
	called instantly.*/
var float MinWallDistance;

/* How much further away the wall will spawn per DeltaTime of charging up */
var float ChargeDistance;


<<<<<<< HEAD

simulated function StartFire(byte FireModeNum)
{
	local vector loc;
	
	loc = vect(1, 0, 0) << Instigator.Rotation;
	
	//This checks that we hit the floor, and that we don't hit the ceiling, before trying to cast the ability.
	if (!FastTrace(Instigator.Location + vect(0, 0, -1) * Range + loc, Instigator.Location + loc) &&
		FastTrace(Instigator.Location + vect(0, 0, 1) * Height + loc, Instigator.Location + loc))
 		super.StartFire(FireModeNum);
}

simulated function FireAmmunition()
{
	SummonWall((ChargeTime * ChargeDistance) + MinWallDistance);
	
	super.FireAmmunition();
}

simulated function SummonWall(float Dist)
{
	local vector traceLoc, traceNorm, loc;

	//This is a neat little operator.  The << operator takes a vector and a rotation, and returns the 
	//rotated wector.  So no need to screw around with trig, it does it for you.
	loc = vect(1, 0, 0) << Instigator.Rotation;
	
	loc.x *= Dist;
	loc.y *= -Dist;

	if (Trace(traceLoc, traceNorm, Instigator.Location + vect(0, 0, -1) * Range + loc, Instigator.Location + loc) != None)
		Wall = Spawn(class 'Arena.Ab_RockWallBoulder', None, , traceLoc + (vect(0, 0, -1) * StartDepth), Instigator.Rotation);
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
	
	StartDepth=150
	Range=120
	Height=200
	MinWallDistance = 120
	ChargeDistance = 191.2

	MinCharge=0.0
	MaxCharge=3.0
}
