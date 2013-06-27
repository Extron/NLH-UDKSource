/*******************************************************************************
	L_ShockLight

	Creation date: 12/06/2013 14:43
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class L_ShockLight extends UDKExplosionLight;

defaultproperties
{
	HighDetailFrameTime=+0.02
	Lifetime=0.25
	Brightness=64
	Radius=512
	LightColor=(R=128,G=128,B=255,A=255)

	TimeShift=((StartTime=0.0,Radius=512,Brightness=64,LightColor=(R=128,G=128,B=255,A=255)),(StartTime=0.2,Radius=256,Brightness=16,LightColor=(R=128,G=128,B=255,A=255)))
}