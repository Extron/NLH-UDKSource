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

simulated function PlayAnimation(name sequence, optional float duration, optional bool loop)
{
	local AnimNodePlayCustomAnim node;

	if (WorldInfo.NetMode == NM_DedicatedServer || ArenaPawn(Owner) == None|| !ArenaPawn(Owner).IsFirstPerson() || MeshComponent == None)
		return;

	node = AnimNodePlayCustomAnim(AnimTree(MeshComponent.Animations).Children[0].Anim);

	if (node == None)
		return;

	node.PlayCustomAnim(sequence, 1.0, , , loop);
}

simulated function AnimNodePlayCustomAnim GetAnimNode()
{
	if (MeshComponent != None)
		return AnimNodePlayCustomAnim(AnimTree(MeshComponent.Animations).Children[0].Anim);

	return None;
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
		AnimTreeTemplate=AnimTree'AC_Player.Animations.MovementAnimationTree'
		AnimSets[0]=AnimSet'AC_Player.Animations.MovementAnimations'
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