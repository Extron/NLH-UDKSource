/*******************************************************************************
	PAC_BodyPart

	Creation date: 16/07/2014 00:00
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class BodyPartComponent extends PlayerAppearanceComponent;

enum BodyPartType
{
	BPTHead,
	BPTLeftArm,
	BPTRightArm,
	BPTLeftLeg,
	BPTRightLeg,
	BPTTorso
};

/**
 * A list of current armor attachments attached to this component.
 */
var array<ArmorAttachment> Attachments;

/**
 * The type of the body part.
 */
var BodyPartType Type;


simulated function AttachArmor(ArmorAttachment armor)
{
	armor.AttachToComponent(self);
	Attachments.AddItem(armor);
}

function SetFOV(float angle)
{
	local ArmorAttachment iter;
	
	super.SetFOV(angle);

	foreach Attachments(iter)
		iter.MeshComponent.SetFOV(angle);
}