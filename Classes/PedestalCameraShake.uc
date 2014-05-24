/*******************************************************************************
	PedestalCameraShake

	Creation date: 05/04/2014 22:48
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class PedestalCameraShake extends CameraShake;

defaultproperties
{
	OscillationDuration=0
	OscillationBlendInTime=0.1
	OscillationBlendOutTime=0.1
	AnimBlendInTime=0.1
	AnimBlendOutTime=0.1
	RotOscillation={(Pitch=(Amplitude=150,Frequency=40), Yaw=(Amplitude=150,Frequency=30), Roll=(Amplitude=150,Frequency=60))}
}