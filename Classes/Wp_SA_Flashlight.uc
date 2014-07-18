/*******************************************************************************
	Wp_SA_Flashlight

	Creation date: 07/06/2013 23:27
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_SA_Flashlight extends Wp_SideAttachment;


/**
 * The flashlight's light.
 */
var SpotLightComponent Light;

var MaterialInstanceConstant Material;

var float EmissionFactor;

var bool On;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	SkeletalMeshComponent(Mesh).AttachComponentToSocket(Light, 'LightSocket');
	
	Material = new class'MaterialInstanceConstant';
	Material.SetParent(Mesh.GetMaterial(0));
	Material.SetScalarParameterValue('EmissionFactor', On ? EmissionFactor : 0.0);
	
	Mesh.SetMaterial(0, Material);
	
	Light.SetEnabled(On);
}

event Destroyed()
{
	super.Destroyed();
	
	DetachComponent(Light);
}

/**
 * Flashlights can be toggled on or off.
 */
simulated function Toggle()
{
	Light.SetEnabled(!Light.bEnabled);
	On = !On;
	Material.SetScalarParameterValue('EmissionFactor', On ? EmissionFactor : 0.0);
}

defaultproperties
{
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'RailSideAttachments.Meshes.Flashlight'
	End Object
	
	Begin Object Class=SpotLightComponent Name=SLC
		Radius=2048
		Brightness=2.5
		OuterConeAngle=30
	End Object
	Light=SLC
	
	CompatibleTypes[0]=WTRifle
	CompatibleTypes[1]=WTShotgun
	CompatibleTypes[2]=WTHardLightRifle
	CompatibleTypes[3]=WTGrenadeLauncher
	CompatibleTypes[4]=WTRocketLauncher
	CompatibleTypes[5]=WTBeamRifle
	CompatibleTypes[6]=WTPlasmaRifle
	CompatibleTypes[7]=WTRailGun
	
	CompatibleSizes[0]=WSSmall
	CompatibleSizes[1]=WSRegular
	CompatibleSizes[2]=WSLarge
	CompatibleSizes[3]=WSHand
	CompatibleSizes[4]=WSHeavy
	
	On=true
	EmissionFactor=50
	
	Weight=1
	Cost=2
	ComponentName="Flashlight"
	ComponentDescription="Though batteries are relatively rare, Old World tech can last a nearly unlimited amount of time using batteries from that era.  Many scavanged flashlights, if cleaned properly, are perfectly functional."
}