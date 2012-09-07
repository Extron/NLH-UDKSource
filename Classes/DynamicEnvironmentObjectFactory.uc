/*******************************************************************************
	DynamicEnvironmentObjectFactory

	Creation date: 29/07/2012 20:47
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class DynamicEnvironmentObjectFactory extends ActorFactoryRigidBody;

defaultproperties
{
	MenuName="Add Dynamic Environment Object"
	NewActorClass=class'DynamicEnvironmentObject'
}