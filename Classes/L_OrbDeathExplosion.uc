/*******************************************************************************
	L_OrbDeathExplosion

	Creation date: 12/05/2013 12:51
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class L_OrbDeathExplosion extends UDKExplosionLight;

defaultproperties
{
	HighDetailFrameTime=+0.02
	Lifetime=0.45
	Brightness=32
	Radius=256
	LightColor=(R=236,G=236,B=255,A=255)

	TimeShift=((StartTime=0.0,Radius=384,Brightness=32,LightColor=(R=128,G=236,B=255,A=255)),(StartTime=0.1,Radius=128,Brightness=8,LightColor=(R=64,G=128,B=255,A=255)))
}