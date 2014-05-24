/*******************************************************************************
	PedestalCSV

	Creation date: 05/04/2014 22:45
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * The camera shake volume to use for the pedestal.
 */
class PedestalCSV extends CameraShakeVolume;

defaultproperties
{
	Begin Object Name=CollisionCylinder
		CollisionRadius=1024
		CollisionHeight=1024
		CollideActors=true        
        BlockActors=false
	End Object
	
	LinearAttenuation=0.0009765625
	
	CameraShakeClass=class'Arena.PedestalCameraShake'
	Lifetime=2.5
}