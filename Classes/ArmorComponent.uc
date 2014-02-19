/*******************************************************************************
	ArmorComponent

	Creation date: 08/02/2014 13:47
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * A piece of armor that the player can attach or wear.
 */
class ArmorComponent extends Actor;

enum ArmorComponentType
{
	ACTHead,
	ACTLeftArm,
	ACTRightArm,
	ACTLeftLeg,
	ACTRightLeg,
	ACTTorso,
	ACTAttachment
};

/**
 * The mesh component used to draw the armor.
 */
var SkeletalMeshComponent MeshComponent;

/**
 * The player stat modifier for the armor.
 */
var PlayerStatModifier StatMod;

/**
 * The type of the armor.
 */
var ArmorComponentType Type;

/**
 * The energy cost of attaching the armor.
 */
var float EnergyCost;

/**
 * Allows armor to indicate that they are active or not.
 */
var bool Active;

/**
 * The slot that the armor will go in to specify which button activates it.
 */
var int Slot; 


/**
 * An overriddable method that allows armor to specify what they do when activated.
 */
event Activate()
{
}

defaultproperties
{
	Begin Object Class=PlayerStatModifier Name=PSM
	End Object
	StatMod=PSM
	
	Begin Object Class=SkeletalMeshComponent Name=Mesh
		bCacheAnimSequenceNodes=FALSE
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		bOwnerNoSee=false
		bOnlyOwnerSee=true
		CastShadow=FALSE
		BlockRigidBody=TRUE
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=TRUE
		bUpdateKinematicBonesFromAnimation=true
		bCastDynamicShadow=true
		RBChannel=RBCC_Untitled3
		RBCollideWithChannels=(Untitled3=true)
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=FALSE
		AnimTreeTemplate=AnimTree'AC_Player.Animations.ArmsAnimTree'
		AnimSets[0]=AnimSet'AC_Player.Animations.ArmsAnimSet'
		bHasPhysicsAssetInstance=true
		TickGroup=TG_PreAsyncWork
		bChartDistanceFactor=true
		MinDistFactorForKinematicUpdate=0.2
		RBDominanceGroup=20
		bUseOnePassLightingOnTranslucency=TRUE
		bPerBoneMotionBlur=true
	End Object
	MeshComponent=Mesh
	
	Slot=-1
}