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

function bool IsOfSameType(class<PlayerAppearanceComponent> component)
{
	if (class<BodyPartComponent>(component) == None)
		return false;
		
	return class<BodyPartComponent>(component).default.Type == Type;
}

defaultproperties
{
	Subclasses[0]=class'Arena.BPC_Head';
	Subclasses[1]=class'Arena.BPC_LeftArmNude';
	Subclasses[2]=class'Arena.BPC_RightArmNude';
	Subclasses[3]=class'Arena.BPC_LeftLegNude';
	Subclasses[4]=class'Arena.BPC_RightLegNude';
	Subclasses[5]=class'Arena.BPC_TorsoNude';
	Subclasses[6]=class'Arena.BPC_LeftArmRobotForearm';
	Subclasses[7]=class'Arena.BPC_RightArmRobotForearm';
}