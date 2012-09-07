/*******************************************************************************
	EnvironmentObjectFactory

	Creation date: 08/07/2012 18:20
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class EnvironmentObjectFactory extends ActorFactoryStaticMesh;

defaultproperties
{
	MenuName="Add Static Environment Object"
	NewActorClass=class'EnvironmentObject'
}