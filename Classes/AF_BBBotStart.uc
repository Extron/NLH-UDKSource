/*******************************************************************************
	AF_BBBotStart

	Creation date: 04/04/2013 17:51
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class AF_BBBotStart extends ActorFactoryPlayerStart;

defaultproperties
{
	MenuName="Add Bot Battle Bot Start"
	NewActorClass=class'Arena.BBBotStart'
	bShowInEditorQuickMenu=true
}