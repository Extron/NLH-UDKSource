/*******************************************************************************
	Pawn_HeadData

	Creation date: 20/06/2014 19:56
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

/**
 * This object stores all the data needed to draw the player's head, such as morph target weights, hair styles and colors, and eye colors.
 */
class Pawn_HeadData extends Object;

struct MorphData
{
	/**
	 * The morph target's name.
	 */
	var name MorphName;
	
	/**
	 * The weight given to the morph target.  The range is 0 - 1 for single side morphs and -1 - 1 for double sided morphs.
	 */
	var float MorphWeight;
	
	/**
	 * The category that the morph weight is under in the UI.
	 */
	var string Category;
	
	/**
	 * The display name of the morph, for drawing to the UI.
	 */
	var string DisplayName;
	
	/**
	 * Most morph targets for the head have both a negative side and a positive side (named MorphName + 0 or MorphName + 1 respectively.
	 * This indicates that this morph data refers to such a target.
	 */
	var bool DoubleSided;
};

var array<MorphData> Morphs;

/**
 * The eye color used for the head.
 */
var LinearColor EyeColor;

/**
 * The hair color used for the head.
 */
var LinearColor HairColor;

/**
 * The name of the (head) hair mesh the player has.
 */
var string HairMesh;

/**
 * The name of the eyebrows that the player has.
 */
var string Eyebrows;

defaultproperties
{
	HairMesh=""
	HairColor=(R=0,G=0,B=0,A=1)
	EyeColor=(R=0,G=0,B=1,A=1)
	
	Morphs[0]=(MorphName=African,DoubleSided=false,Category="Race")
	Morphs[1]=(MorphName=Asian,DoubleSided=false,Category="Race")
	Morphs[2]=(MorphName=Female,DoubleSided=false,Category="Gender")
	
	Morphs[3]=(MorphName=CH-Height,DoubleSided=true,Category="Chin",DisplayName="Height")
	Morphs[4]=(MorphName=CH-Jaw,DoubleSided=true,Category="Chin",DisplayName="Jaw")
	Morphs[5]=(MorphName=CH-Jut,DoubleSided=true,Category="Chin",DisplayName="Jut")
	Morphs[6]=(MorphName=CH-Prominent,DoubleSided=true,Category="Chin",DisplayName="Prominence")
	Morphs[7]=(MorphName=CH-Width,DoubleSided=true,Category="Chin",DisplayName="Width")
	
		
	Morphs[8]=(MorphName=CK-Bone,DoubleSided=true,Category="Cheek",DisplayName="Bone Size")
	Morphs[9]=(MorphName=CK-Inner,DoubleSided=true,Category="Cheek",DisplayName="Inner Size")
	Morphs[10]=(MorphName=CK-TransVert,DoubleSided=true,Category="Cheek",DisplayName="Vertical Position")
	Morphs[11]=(MorphName=CK-Volume,DoubleSided=true,Category="Cheek",DisplayName="Volume")
	
	Morphs[12]=(MorphName=E-HorizPos,DoubleSided=true,Category="Eyes",DisplayName="Horizontal Position")
	Morphs[13]=(MorphName=E-Size,DoubleSided=true,Category="Eyes",DisplayName="Size")
	Morphs[14]=(MorphName=E-Tilt,DoubleSided=true,Category="Eyes",DisplayName="Tilt")
	Morphs[15]=(MorphName=E-VertPos,DoubleSided=true,Category="Eyes",DisplayName="Vertical Position")
	
	Morphs[16]=(MorphName=EB-Angle,DoubleSided=true,Category="Eyebrows",DisplayName="Angle")
	Morphs[17]=(MorphName=EB-TransDepth,DoubleSided=true,Category="Eyebrows",DisplayName="Depth")
	Morphs[18]=(MorphName=EB-TransVert,DoubleSided=true,Category="Eyebrows",DisplayName="Vertical Position")
	
	Morphs[19]=(MorphName=ER-Flap,DoubleSided=true,Category="Ears",DisplayName="Flap")
	Morphs[20]=(MorphName=ER-Height,DoubleSided=true,Category="Ears",DisplayName="Height")
	Morphs[21]=(MorphName=ER-Lobe,DoubleSided=true,Category="Ears",DisplayName="Lobe")
	Morphs[22]=(MorphName=ER-Rot,DoubleSided=true,Category="Ears",DisplayName="Rotation")
	Morphs[23]=(MorphName=ER-Tip,DoubleSided=true,Category="Ears",DisplayName="Tip")
	Morphs[24]=(MorphName=ER-TransVert,DoubleSided=true,Category="Ears",DisplayName="Vertical Position")
	Morphs[25]=(MorphName=ER-Width,DoubleSided=true,Category="Ears",DisplayName="Width")
	Morphs[26]=(MorphName=ER-Wing,DoubleSided=true,Category="Ears",DisplayName="Wing")
	
	Morphs[27]=(MorphName=F-ScaleVert,DoubleSided=true,Category="Forehead",DisplayName="Vertical Scale")
	Morphs[28]=(MorphName=F-Temples,DoubleSided=true,Category="Forehead",DisplayName="Temples")
	Morphs[29]=(MorphName=F-TransDepth,DoubleSided=true,Category="Forehead",DisplayName="Depth")
	
	Morphs[30]=(MorphName=M-LipVolume,DoubleSided=true,Category="Mouth",DisplayName="Lip Volume")
	Morphs[31]=(MorphName=M-ScaleDepth,DoubleSided=true,Category="Mouth",DisplayName="Depth Scale")
	Morphs[32]=(MorphName=M-ScaleHoriz,DoubleSided=true,Category="Mouth",DisplayName="Horizontal Scale")
	Morphs[33]=(MorphName=M-ScaleVert,DoubleSided=true,Category="Mouth",DisplayName="Vertical Scale")
	Morphs[34]=(MorphName=M-TransDepth,DoubleSided=true,Category="Mouth",DisplayName="Depth")
	Morphs[35]=(MorphName=M-TransVert,DoubleSided=true,Category="Mouth",DisplayName="Vertical Position")
	Morphs[36]=(MorphName=M-UpperLipAngle,DoubleSided=true,Category="Mouth",DisplayName="Angle")
	
	Morphs[37]=(MorphName=N-BridgeWidth,DoubleSided=true,Category="Nose",DisplayName="Bridge Width")
	Morphs[38]=(MorphName=N-Curve,DoubleSided=true,Category="Nose",DisplayName="Curve")
	Morphs[39]=(MorphName=N-Height,DoubleSided=true,Category="Nose",DisplayName="Height")
	Morphs[40]=(MorphName=N-MidWidth,DoubleSided=true,Category="Nose",DisplayName="Mid Width")
	Morphs[41]=(MorphName=N-NostrilWidth,DoubleSided=true,Category="Nose",DisplayName="Nostril Width")
	Morphs[42]=(MorphName=N-Point,DoubleSided=true,Category="Nose",DisplayName="Point")
	Morphs[43]=(MorphName=N-PointWidth,DoubleSided=true,Category="Nose",DisplayName="Point Width")
	Morphs[44]=(MorphName=N-ScaleDepth,DoubleSided=true,Category="Nose",DisplayName="Depth Scale")
	Morphs[45]=(MorphName=N-ScaleHoriz,DoubleSided=true,Category="Nose",DisplayName="Horizontal Scale")
	Morphs[46]=(MorphName=N-ScaleVert,DoubleSided=true,Category="Nose",DisplayName="Vertical Scale")
	Morphs[47]=(MorphName=N-Tip,DoubleSided=true,Category="Nose",DisplayName="Tip")
	Morphs[48]=(MorphName=N-TransDepth,DoubleSided=true,Category="Nose",DisplayName="Depth")
	Morphs[49]=(MorphName=N-TransVert,DoubleSided=true,Category="Nose",DisplayName="Vertical Position")
	Morphs[50]=(MorphName=N-Width,DoubleSided=true,Category="Nose",DisplayName="Width")
}