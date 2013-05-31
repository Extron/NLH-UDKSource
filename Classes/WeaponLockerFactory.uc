/*******************************************************************************
	WeaponLockerFactory

	Creation date: 27/05/2013 23:15
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class WeaponLockerFactory extends ActorFactoryActor;

defaultproperties
{
	MenuName="Add Weapon Locker"
	ActorClass=class'Arena.WeaponLocker'
	bPlaceable=true
	bShowInEditorQuickMenu=true
}