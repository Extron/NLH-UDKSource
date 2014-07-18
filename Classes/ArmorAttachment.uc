/*******************************************************************************
	ArmorAttachment

	Creation date: 03/06/2014 21:37
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

/**
 * A non-skinned armor attachment that is connected to the player via a socket.
 */
class ArmorAttachment extends Actor
	dependson(BodyPartComponent);

/**
 * The mesh of the armor attachment.
 */
var UDKSkeletalMeshComponent MeshComponent;

/**
 * The armor component type to attach to.
 */
var BodyPartType AttachComponentType;

/**
 * The name of the socket to attach to.
 */
var name AttachSocket;

simulated function AttachToComponent(BodyPartComponent component)
{
	component.MeshComponent.AttachComponentToSocket(MeshComponent, AttachSocket);
	MeshComponent.SetFOV(component.MeshComponent.FOV);
}

defaultproperties
{
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
}