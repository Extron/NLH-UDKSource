/*******************************************************************************
	AP_Armor

	Creation date: 05/02/2014 16:30
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * This class stores all of the mods and stats for the armor that the player is wearing.
 */
class AP_Armor extends Actor;

enum ArmorBase
{
	ABRightArm,
	ABLeftArm,
	ABRightLeg,
	ABLeftLeg,
	ABTorso,
	ABAbdomin,
	ABHead
}

/**
 * A list of the base parts used to draw the player, including arms, legs, torso, and head.
 */
var array<SkeletalMeshComponent> BaseParts;

/**
 * The player stat modifiers for each base part.
 */
var array<PlayerStatModifier> BaseStatMods;


function AttachBaseMods(AP_Player player)
{
	local int i;
	
	for (i = 0; i < BaseParts.Length; i++)
	{
		player.AttachComponent(BaseParts[i]);
		player.AddStatMod(BaseStatMods[i]);
	}
}