/*******************************************************************************
	AA_AbilitySlotBand

	Creation date: 03/06/2014 21:53
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class AA_AbilitySlotBand extends ArmorAttachment;

defaultproperties
{
	Begin Object Name=Mesh
		SkeletalMesh=SkeletalMesh'ArmAttachments.Meshes.AbilitySlotBand'
	End Object
	
	AttachComponentType=BPTLeftArm
	AttachSocket=LeftWristAttachmentSocket
}