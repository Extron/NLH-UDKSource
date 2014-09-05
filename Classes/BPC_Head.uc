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
	local LinearColor white;
	
	super.PreBeginPlay();
	
	white.r = 1.0;
	white.g = 1.0;
	white.b = 1.0;
	
	EyeMaterial = new class'MaterialInstanceConstant';
	EyeMaterial.SetParent(MeshComponent.GetMaterial(0));
	EyeMaterial.SetVectorParameterValue('IrisColor', white);
	MeshComponent.SetMaterial(0, EyeMaterial);
	
	hairMesh = SkeletalMesh(DynamicLoadObject(class'Arena.Pawn_HeadData'.default.HairPieces[HeadData.HairMesh].MeshReference, class'SkeletalMesh'));

	if (hairMesh != None)
	{
		HairMeshComponent.SetSkeletalMesh(hairMesh);
		HairMeshComponent.MorphSets[0] = MorphTargetSet(DynamicLoadObject(class'Arena.Pawn_HeadData'.default.HairPieces[HeadData.HairMesh].MorphSetReference, class'MorphTargetSet'));
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
	
	`log(self @ "PostInitAnimTree");
	if (MeshComponent == mesh)
	{
		for (i = 0; i < HeadData.Morphs.Length; i++)
		{
			if (HeadData.Morphs[i].DoubleSided)
			{
				node = MorphNodeWeight(mesh.FindMorphNode(name(string(HeadData.Morphs[i].MorphName) $ "0")));
				
				if (node != None)
				{
					HeadData.Morphs[i].LeftHeadMorphNode = node;
					node.SetNodeWeight(FClamp(-HeadData.Morphs[i].MorphWeight, 0, 1));
				}
				
				node = MorphNodeWeight(mesh.FindMorphNode(name(string(HeadData.Morphs[i].MorphName) $ "1")));
				
				if (node != None)
				{
					HeadData.Morphs[i].RightHeadMorphNode = node;
					node.SetNodeWeight(FClamp(HeadData.Morphs[i].MorphWeight, 0, 1));
				}
			}
			else
			{
				node = MorphNodeWeight(mesh.FindMorphNode(HeadData.Morphs[i].MorphName));
				
				if (node != None)
				{
					HeadData.Morphs[i].LeftHeadMorphNode = node;
					HeadData.Morphs[i].RightHeadMorphNode = node;
					node.SetNodeWeight(FClamp(HeadData.Morphs[i].MorphWeight, 0, 1));
				}
			}
		}
	}
	
	if (HairMeshComponent == mesh)
	{
		`log("Loading hair morph nodes");
		for (i = 0; i < HeadData.Morphs.Length; i++)
		{
			if (HeadData.Morphs[i].DoubleSided)
			{
				node = MorphNodeWeight(mesh.FindMorphNode(name(string(HeadData.Morphs[i].MorphName) $ "0")));
				
				`log("Node" @ node);
				
				if (node != None)
				{
					HeadData.Morphs[i].LeftHairMorphNode = node;
					node.SetNodeWeight(FClamp(-HeadData.Morphs[i].MorphWeight, 0, 1));
				}
				
				node = MorphNodeWeight(mesh.FindMorphNode(name(string(HeadData.Morphs[i].MorphName) $ "1")));
				
				if (node != None)
				{
					HeadData.Morphs[i].RightHairMorphNode = node;
					node.SetNodeWeight(FClamp(HeadData.Morphs[i].MorphWeight, 0, 1));
				}
			}
			else
			{
				node = MorphNodeWeight(mesh.FindMorphNode(HeadData.Morphs[i].MorphName));
								
				`log("Node" @ node);
				
				if (node != None)
				{
					HeadData.Morphs[i].LeftHairMorphNode = node;
					HeadData.Morphs[i].RightHairMorphNode = node;
					node.SetNodeWeight(FClamp(HeadData.Morphs[i].MorphWeight, 0, 1));
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

function SetFacialFeatureMorphValue(string featureName, string featureCategory, float featureValue)
{
	local int morphData;
	local int i;
	
	for (i = 0; i < HeadData.Morphs.Length; i++)
	{
		if (HeadData.Morphs[i].Category == featureCategory && HeadData.Morphs[i].DisplayName == featureName)
		{
			morphData = i;
			break;
		}
	}
	
	if (HeadData.Morphs[morphData].DoubleSided)
		HeadData.Morphs[morphData].MorphWeight = 2 * featureValue - 1;
	else
		HeadData.Morphs[morphData].MorphWeight = featureValue;
	
	if (MeshComponent != None)
	{
		if (HeadData.Morphs[morphData].DoubleSided)
		{
			if (HeadData.Morphs[morphData].LeftHeadMorphNode != None)
				HeadData.Morphs[morphData].LeftHeadMorphNode.SetNodeWeight(FClamp(-HeadData.Morphs[morphData].MorphWeight, 0, 1));
			
			if (HeadData.Morphs[morphData].RightHeadMorphNode != None)
				HeadData.Morphs[morphData].RightHeadMorphNode.SetNodeWeight(FClamp(HeadData.Morphs[morphData].MorphWeight, 0, 1));
		}
		else
		{
			if (HeadData.Morphs[morphData].LeftHeadMorphNode != None)
				HeadData.Morphs[morphData].LeftHeadMorphNode.SetNodeWeight(FClamp(HeadData.Morphs[morphData].MorphWeight, 0, 1));
		}
	}
	
	if (HairMeshComponent != None)
	{
		if (HeadData.Morphs[morphData].DoubleSided)
		{
			`log(HeadData.Morphs[morphData].LeftHeadMorphNode @ HeadData.Morphs[morphData].LeftHairMorphNode);
			
			if (HeadData.Morphs[morphData].LeftHairMorphNode != None)
				HeadData.Morphs[morphData].LeftHairMorphNode.SetNodeWeight(FClamp(-HeadData.Morphs[morphData].MorphWeight, 0, 1));

			if (HeadData.Morphs[morphData].RightHairMorphNode != None)
				HeadData.Morphs[morphData].RightHairMorphNode.SetNodeWeight(FClamp(HeadData.Morphs[morphData].MorphWeight, 0, 1));
		}
		else
		{
			if (HeadData.Morphs[morphData].LeftHairMorphNode != None)
				HeadData.Morphs[morphData].LeftHairMorphNode.SetNodeWeight(FClamp(HeadData.Morphs[morphData].MorphWeight, 0, 1));
		}
	}
}

function SetEyeColor(Color newColor)
{
	HeadData.EyeColor = ColorToLinearColor(newColor);
	EyeMaterial.SetVectorParameterValue('IrisColor', HeadData.EyeColor);
}

function SetHairColor(Color newColor)
{
	HeadData.HairColor = ColorToLinearColor(newColor);
	if (HairMaterial != None) HairMaterial.SetVectorParameterValue('DiffuseTint', HeadData.HairColor);
}

function SetHairMesh(int hairStyleIndex)
{
	local SkeletalMesh hairMesh;
	
	HeadData.HairMesh = hairStyleIndex;
	
	hairMesh = SkeletalMesh(DynamicLoadObject(class'Arena.Pawn_HeadData'.default.HairPieces[HeadData.HairMesh].MeshReference, class'SkeletalMesh'));
	
	if (hairMesh != None)
	{
		`log("Morph set" @ class'Arena.Pawn_HeadData'.default.HairPieces[HeadData.HairMesh].MorphSetReference);
		
		HairMeshComponent.MorphSets.Length = 0;
		
		HairMeshComponent.SetHidden(false);
		HairMeshComponent.SetSkeletalMesh(hairMesh);
		HairMeshComponent.MorphSets[0] = MorphTargetSet(DynamicLoadObject(class'Arena.Pawn_HeadData'.default.HairPieces[HeadData.HairMesh].MorphSetReference, class'MorphTargetSet'));
		HairMaterial.SetParent(MaterialInterface(DynamicLoadObject(class'Arena.Pawn_HeadData'.default.HairPieces[HeadData.HairMesh].MaterialReference, class'MaterialInterface')));
		//MeshComponent.AttachComponentToSocket(HairMeshComponent, 'HairSocket');
		
		//HairMaterial = new class'MaterialInstanceConstant';
		//HairMaterial.SetParent(HairMeshComponent.GetMaterial(0));
		//HairMaterial.SetVectorParameterValue('HairColor', HeadData.HairColor);
		//HairMeshComponent.SetMaterial(0, HairMaterial);
	}
	else
	{
		HairMeshComponent.SetHidden(true);
	}
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
		AnimTreeTemplate=AnimTree'Head.Animations.DHAnimationTree'
		AnimSets[0]=AnimSet'AC_Player.Animations.MovementAnimations'
		MorphSets[0]=MorphTargetSet'Head.Morphs.DefaultHead_FeatureSet'
		bHasPhysicsAssetInstance=true
		TickGroup=TG_PreAsyncWork
		bChartDistanceFactor=true
		MinDistFactorForKinematicUpdate=0.2
		RBDominanceGroup=20
		bUseOnePassLightingOnTranslucency=TRUE
		bPerBoneMotionBlur=true
	End Object
	HairMeshComponent=Hair
	Components.Add(Hair)
	
	Begin Object Class=Pawn_HeadData Name=PawnHeadData
	End Object
	HeadData=PawnHeadData
	
	Type=BPTHead
}