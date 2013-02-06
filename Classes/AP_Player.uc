/*******************************************************************************
	AP_Player

	Creation date: 12/01/2013 22:03
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class AP_Player extends ArenaPawn;

/**
 * The arms used for first person animations are kept separate from the rest of the 
 * pawn's mesh for simplicity.
 */
var SkeletalMeshComponent Arms;

/**
 * The translation to apply to the arms when drawing them.
 */
var vector ArmsTranslation;


function InitInventory()
{
	local ArenaWeapon newWeapon;
	
	super.InitInventory();
	
	if (ArenaPlayerController(Owner) != None && ArenaPlayerController(Owner).Loadout != None && ArenaPlayerController(Owner).Loadout.Weapon != None)
	{
		newWeapon = CreateWeapon(ArenaPlayerController(Owner).Loadout.Weapon);
	}
	
	if (ArenaInventoryManager(InvManager) != None)
	{	
		if (newWeapon != None)
		{
			InvManager.AddInventory(newWeapon);
			InvManager.NextWeapon();
		}
		
		// This sets the defualt class
		CreateInventory(class'Arena.Ab_Bubble', true);
		ArenaInventoryManager(InvManager).NextAbility();
	}
}

/**
 * Gets the location that abilities will fire from.  Preferrably, this will be the location of the
 * player's right or left hand (as per player handedness).
 */
function GetAbilitySourceOffset(out vector l, out rotator r)
{	
	if (Arms.GetSocketByName('LeftHandSocket') != None)
		Arms.GetSocketWorldLocationAndRotation('LeftHandSocket', l, r, 0);
}

function GetWeaponSourceOffset(out vector l, out rotator r)
{	
	if (Arms.GetSocketByName('RightHandSocket') != None)
		Arms.GetSocketWorldLocationAndRotation('RightHandSocket', l, r, 0);
}

simulated function PositionArms()
{
	local rotator R;
	
	R = Arms.Rotation;
	
	if (Controller != None)
		R.Pitch = Controller.Rotation.Pitch;
	
	Arms.SetTranslation(ArmsTranslation);
	Arms.SetRotation(R);
	//SetBase(Holder);
}

defaultproperties
{
	Begin Object Class=SkeletalMeshComponent Name=ArmsMesh
		SkeletalMesh=SkeletalMesh'AC_Player.Meshes.PlayerArmsMesh'
		PhysicsAsset=PhysicsAsset'AC_Player.Physics.PlayerArmsMeshPhysics'
		Scale=0.95
		bCacheAnimSequenceNodes=FALSE
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		bOwnerNoSee=false
		CastShadow=FALSE
		BlockRigidBody=TRUE
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=TRUE
		bUpdateKinematicBonesFromAnimation=true
		bCastDynamicShadow=true
		RBChannel=RBCC_Untitled3
		RBCollideWithChannels=(Untitled3=true)
		LightEnvironment=MyLightEnvironment
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=FALSE
		AnimTreeTemplate=AnimTree'AC_Player.Animations.PlayerArmsAnimTree'
		AnimSets[0]=AnimSet'AC_Player.Animations.PlayerArmsAnim'
		bHasPhysicsAssetInstance=true
		TickGroup=TG_PreAsyncWork
		bChartDistanceFactor=true
		MinDistFactorForKinematicUpdate=0.2
		RBDominanceGroup=20
		bUseOnePassLightingOnTranslucency=TRUE
		bPerBoneMotionBlur=true
	End Object 
	Arms=ArmsMesh
	Components.Add(ArmsMesh)
	
	ArmsTranslation=(X=-5,Y=-2,Z=45)
}