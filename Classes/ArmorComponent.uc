/*******************************************************************************
	ArmorComponent

	Creation date: 08/02/2014 13:47
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * A piece of armor that the player can attach or wear.
 */
class ArmorComponent extends PlayerAppearanceComponent;

enum ArmorComponentType
{
	ACTHelmet,
	ACTEyeImplant,
	ACTLeftUpperArm,
	ACTLeftForearm,
	ACTRightUpperArm,
	ACTRightForearm,
	ACTLeftThigh,
	ACTLeftFoot,
	ACTRightThigh,
	ACTRightFoot,
	ACTTorso,
	ACTSpinalImplant
};

/**
 * The armor type, which defines which armor slot the armor component can fill.
 */
var ArmorComponentType Type;


/**
 * An overriddable method that allows armor to specify what they do when activated.
 */
event Activate()
{
}

simulated function PlayAnimation(name sequence, optional float duration, optional bool loop, optional float blendIn, optional float blendOut)
{
	local AnimNodePlayCustomAnim node;

	if (WorldInfo.NetMode == NM_DedicatedServer || ArenaPawn(Owner) == None || 
		!ArenaPawn(Owner).IsFirstPerson() || MeshComponent == None || MeshComponent.Animations == None)
		return;

	node = AnimNodePlayCustomAnim(AnimTree(MeshComponent.Animations).Children[0].Anim);
	
	if (node == None)
		return;
		
	node.PlayCustomAnim(sequence, 1.0, blendIn, blendOut, loop);
}

simulated function AnimNodePlayCustomAnim GetAnimNode()
{
	if (MeshComponent != None)
		return AnimNodePlayCustomAnim(AnimTree(MeshComponent.Animations).Children[0].Anim);

	return None;
}

function bool IsOfSameType(class<PlayerAppearanceComponent> component)
{
	if (class<ArmorComponent>(component) == None)
		return false;
		
	if (component == class'Arena.AC_None')
		return true;
		
	return class<ArmorComponent>(component).default.Type == Type;
}

defaultproperties
{
	Subclasses[0]=class'Arena.AC_None'
	Subclasses[1]=class'Arena.AC_NightVisionOptics'
	Subclasses[2]=class'Arena.AC_ThermalVisionOptics'
}