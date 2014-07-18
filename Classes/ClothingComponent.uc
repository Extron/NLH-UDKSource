/*******************************************************************************
	ClothingComponent

	Creation date: 16/07/2014 00:07
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class ClothingComponent extends PlayerAppearanceComponent;

enum ClothingType
{
	CTShirt,
	CTPants,
	CTGloves,
	CTShoes,
	CTCloak,
	CTHeadwear
};

/**
 * The type of the clothing.
 */
var ClothingType Type;
