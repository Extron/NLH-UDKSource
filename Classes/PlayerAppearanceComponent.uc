/*******************************************************************************
	PlayerAppearanceComponent

	Creation date: 15/07/2014 23:59
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

/**
 * These components are meshes that are drawn as part of the player's avatar.
 */
class PlayerAppearanceComponent extends Actor;

/**
 * A list of all the valid subclasses of this component.
 */
var array<class<PlayerAppearanceComponent> > Subclasses;

/**
 * The mesh component used to draw the armor.
 */
var UDKSkeletalMeshComponent MeshComponent;

/**
 * The player stat modifier for the armor.
 */
var PlayerStatModifier StatMod;

/**
 * The name of the component.
 */
var string ComponentName;

/**
 * The description of the component.
 */
var string ComponentDescription;

/**
 * The icon texture the component uses.
 */
var string ComponentIcon;

/**
 * The energy cost of attaching the armor.
 */
var float EnergyCost;

/**
 * The monetary price of the component.
 */
var float Cost;

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

function SetFOV(float angle)
{
	MeshComponent.SetFOV(angle);
}

function bool IsOfSameType(class<PlayerAppearanceComponent> component)
{
	return true;
}

defaultproperties
{
	Begin Object Class=PlayerStatModifier Name=PSM
	End Object
	StatMod=PSM
	
	Begin Object Class=UDKSkeletalMeshComponent Name=Mesh
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
	Components.Add(Mesh)
	
	Slot=-1
}