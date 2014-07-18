/*******************************************************************************
	ArmorSchematic

	Creation date: 10/02/2014 13:23
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class AvatarSchematic extends Object
	dependson(BodyPartComponent, ArmorComponent, ClothingComponent);

var array<class<BodyPartComponent> > BodyParts;

var array<class<ArmorComponent> > Armor;

var array<class<ClothingComponent> > Clothing;

var array<class<ArmorAttachment> > Attachments;

defaultproperties
{
	BodyParts[BPTHead]=class'Arena.BPC_Head'
	BodyParts[BPTLeftArm]=class'Arena.BPC_LeftArmRobotForearm'
	BodyParts[BPTRightArm]=class'Arena.BPC_RightArmNude'
	BodyParts[BPTLeftLeg]=class'Arena.BPC_LeftLegNude'
	BodyParts[BPTRightLeg]=class'Arena.BPC_RightLegNude'
	BodyParts[BPTTorso]=class'Arena.BPC_TorsoNude'
	
	Armor[ACTHelmet]=class'Arena.AC_None'
	Armor[ACTEyeImplant]=class'Arena.AC_NightVisionOptics'
	Armor[ACTLeftUpperArm]=class'Arena.AC_None'
	Armor[ACTLeftForearm]=class'Arena.AC_None'
	Armor[ACTRightUpperArm]=class'Arena.AC_None'
	Armor[ACTRightForearm]=class'Arena.AC_None'
	Armor[ACTLeftThigh]=class'Arena.AC_None'
	Armor[ACTLeftFoot]=class'Arena.AC_None'
	Armor[ACTRightThigh]=class'Arena.AC_None'
	Armor[ACTRightFoot]=class'Arena.AC_None'
	Armor[ACTTorso]=class'Arena.AC_None'
	Armor[ACTSpinalImplant]=class'Arena.AC_None'
	
	Clothing[CTShirt]=class'Arena.CC_TatteredShirt'
	Clothing[CTPants]=class'Arena.CC_TatteredPants'
	Clothing[CTGloves]=class'Arena.CC_None'
	Clothing[CTShoes]=class'Arena.CC_None'
	Clothing[CTCloak]=class'Arena.CC_None'
	Clothing[CTHeadwear]=class'Arena.CC_None'

	Attachments[0]=class'Arena.AA_AbilitySlotBand'
}
