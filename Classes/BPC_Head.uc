/*******************************************************************************
	AC_Head

	Creation date: 20/06/2014 19:55
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class BPC_Head extends BodyPartComponent;

/**
 * The data used to set the various head settings.
 */
var Pawn_HeadData HeadData;

/**
 * The list of all the head morphing nodes.
 */
var array<MorphNodeWeight> HeadMorphWeights;

/**
 * The list of all the hair morphing nodes.
 */
var array<MorphNodeWeight> HairMorphWeights;

/**
 * The (head) hair mesh that the player has.
 */
var UDKSkeletalMeshComponent HairMeshComponent;

/**
 * The material used for the hair.
 */
var MaterialInstanceConstant HairMaterial;

/**
 * The material used for the eyes.
 */
var MaterialInstanceConstant EyeMaterial;

simulated event PreBeginPlay()
{
	local SkeletalMesh hairMesh;
	
	super.PreBeginPlay();
	
	EyeMaterial = new class'MaterialInstanceConstant';
	EyeMaterial.SetParent(MeshComponent.GetMaterial(0));
	EyeMaterial.SetVectorParameterValue('EyeColor', HeadData.EyeColor);
	MeshComponent.SetMaterial(0, EyeMaterial);
	
	hairMesh = SkeletalMesh(DynamicLoadObject(HeadData.HairMesh, class'SkeletalMesh'));
	
	if (hairMesh != None)
	{
		HairMeshComponent.SetSkeletalMesh(hairMesh);
		MeshComponent.AttachComponentToSocket(HairMeshComponent, 'HairSocket');
		
		HairMaterial = new class'MaterialInstanceConstant';
		HairMaterial.SetParent(HairMeshComponent.GetMaterial(0));
		HairMaterial.SetVectorParameterValue('HairColor', HeadData.HairColor);
		HairMeshComponent.SetMaterial(0, HairMaterial);
	}
}

simulated event PostInitAnimTree(SkeletalMeshComponent mesh)
{
	local MorphNodeWeight node;
	local int i;
	
	if (MeshComponent == mesh)
	{
		for (i = 0; i < HeadData.Morphs.Length; i++)
		{
			if (HeadData.Morphs[i].DoubleSided)
			{
				node = MorphNodeWeight(mesh.FindMorphNode(name(string(HeadData.Morphs[i].MorphName) $ "0")));
				
				if (node != None)
				{
					HeadMorphWeights.AddItem(node);
					node.SetNodeWEight(FClamp(-HeadData.Morphs[i].MorphWeight, 0, 1));
				}
				
				node = MorphNodeWeight(mesh.FindMorphNode(name(string(HeadData.Morphs[i].MorphName) $ "1")));
				
				if (node != None)
				{
					HeadMorphWeights.AddItem(node);
					node.SetNodeWEight(FClamp(HeadData.Morphs[i].MorphWeight, 0, 1));
				}
			}
			else
			{
				node = MorphNodeWeight(mesh.FindMorphNode(HeadData.Morphs[i].MorphName));
				
				if (node != None)
				{
					HeadMorphWeights.AddItem(node);
					node.SetNodeWEight(FClamp(HeadData.Morphs[i].MorphWeight, 0, 1));
				}
			}
		}
	}
	
	if (HairMeshComponent == mesh)
	{
		for (i = 0; i < HeadData.Morphs.Length; i++)
		{
			if (HeadData.Morphs[i].DoubleSided)
			{
				node = MorphNodeWeight(mesh.FindMorphNode(name(string(HeadData.Morphs[i].MorphName) $ "0")));
				
				if (node != None)
				{
					HairMorphWeights.AddItem(node);
					node.SetNodeWEight(FClamp(-HeadData.Morphs[i].MorphWeight, 0, 1));
				}
				
				node = MorphNodeWeight(mesh.FindMorphNode(name(string(HeadData.Morphs[i].MorphName) $ "1")));
				
				if (node != None)
				{
					HairMorphWeights.AddItem(node);
					node.SetNodeWEight(FClamp(HeadData.Morphs[i].MorphWeight, 0, 1));
				}
			}
			else
			{
				node = MorphNodeWeight(mesh.FindMorphNode(HeadData.Morphs[i].MorphName));
				
				if (node != None)
				{
					HairMorphWeights.AddItem(node);
					node.SetNodeWEight(FClamp(HeadData.Morphs[i].MorphWeight, 0, 1));
				}
			}
		}
	}
}

function SetFOV(float angle)
{
	super.SetFOV(angle);

	HairMeshComponent.SetFOV(angle);
}

defaultproperties
{
	Begin Object Name=Mesh
		MorphSets[0]=MorphTargetSet'Head.Morphs.DefaultHead_FeatureSet'
		AnimTreeTemplate=AnimTree'Head.Animations.DHAnimationTree'
		SkeletalMesh=SkeletalMesh'Head.Meshes.DefaultHead'
	End Object
	
	Begin Object Class=UDKSkeletalMeshComponent Name=Hair
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
	HairMeshComponent=Hair
	
	Begin Object Class=Pawn_HeadData Name=PawnHeadData
	End Object
	HeadData=PawnHeadData
	
	Type=BPTHead
}