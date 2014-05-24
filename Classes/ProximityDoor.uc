/*******************************************************************************
	ProximityDoor

	Creation date: 15/03/2014 01:52
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ProximityDoor extends Door
	placeable;

	
/**
 * The radius of the proximity sensor of the door.
 */
var(Door) float Radius;

event Tick(float dt)
{
	local ArenaPawn iter;
	local int nearCount;
	
	foreach VisibleActors(class'Arena.ArenaPawn', iter, Radius)
		nearCount++;
	
	if (nearCount > 0)
		OpenDoor();
	else
		CloseDoor();
}

defaultproperties
{
	Radius=512
}