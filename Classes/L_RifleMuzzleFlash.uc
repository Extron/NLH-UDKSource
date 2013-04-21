/*******************************************************************************
	L_RifleMuzzleFlash

	Creation date: 13/04/2013 02:27
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class L_RifleMuzzleFlash extends UDKExplosionLight;

defaultproperties
{
	HighDetailFrameTime=+0.02
	Lifetime=0.15
	Brightness=32
	Radius=384
	LightColor=(R=255,G=236,B=236,A=255)

	TimeShift=((StartTime=0.0,Radius=384,Brightness=32,LightColor=(R=255,G=236,B=128,A=255)),(StartTime=0.1,Radius=128,Brightness=8,LightColor=(R=255,G=236,B=64,A=255)))
}