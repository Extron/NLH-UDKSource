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
 * The arm control for the left hand, to place on the weapon.
 */
var SkelControlLimb LeftArmControl;

/**
 * The name of the left arm animation control.
 */
var name LeftArmControlName;

/**
 * The translation to apply to the arms when drawing them.
 */
var vector ArmsTranslation;

var RainCylinder RainCylinder;

simulated event TickSpecial(float dt)
{
	local vector gripLoc;
	local rotator gripRot;
	
	super.TickSpecial(dt);
	
	if (ArenaWeapon(Weapon) != None)
	{
		ArenaWeapon(Weapon).GetGripSocketLocRot(gripLoc, gripRot);
		LeftArmControl.EffectorLocation = gripLoc;
	}
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	local AN_BlendBySprint node;

	super.PostInitAnimTree(SkelComp);

	if (SkelComp == Arms)
	{
		RecoilControl = GameSkelCtrl_Recoil(Arms.FindSkelControl(RecoilControlName));
		LeftArmControl = SkelControlLimb(Arms.FindSkelControl(LeftArmControlName));
		LeftArmControl.ControlStrength = 0.0;
		
		EnableLeftHandPositioning(false);
		
		foreach Arms.AllAnimNodes(class'AN_BlendBySprint', node) 
		{
			SprintAnimNodes.AddItem(node);
		}
	}
}

/*
simulated event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser) {

} */

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
		
		CreateInventory(class'Arena.Ab_ShockShort', true);

		ArenaInventoryManager(InvManager).NextAbility();
	}
}

/**
 * Gets the location that abilities will fire from.  Preferrably, this will be the location of the
 * player's right or left hand (as per player handedness).
 */
function GetAbilitySourceOffset(out vector l, out rotator r)
{	
	if (Arms.GetSocketByName('AbilitySourceSocket') != None)
		Arms.GetSocketWorldLocationAndRotation('AbilitySourceSocket', l, r, 0);
}

function GetWeaponSourceOffset(out vector l, out rotator r)
{	
	if (Arms.GetSocketByName('RightHandSocket') != None)
		Arms.GetSocketWorldLocationAndRotation('RightHandSocket', l, r, 0);
}

function AttachToAbilitySource(ActorComponent component)
{
	Arms.AttachComponentToSocket(component, GetAbilityHandSocket());
}

simulated function PositionArms()
{
	local rotator R;
	
	R = Arms.Rotation;
	
	if (Controller != None)
		R.Pitch = Controller.Rotation.Pitch;
	
	Arms.SetTranslation(((ArmsTranslation - vect(0, 0, 1) * EyeHeight) >> R) + vect(0, 0, 1) * EyeHeight);
	Arms.SetRotation(R);
	
	//SetBase(Holder);
}

simulated function EnableLeftHandPositioning(bool enable)
{
	if (LeftArmControl != None)
	{
		if (enable)
			LeftArmControl.ControlStrength = 1.0;
		else
			LeftArmControl.ControlStrength = 0.0;
	}
		
}

simulated function RebootElectronics(ArenaPawn pawn)
{
	if (PlayerController(Controller) != None && ArenaHUD(PlayerController(Controller).MyHUD) != None)
	{
		ArenaHUD(PlayerController(Controller).MyHUD).RebootHUD();
	}
}

exec function GiveAbility(string ability)
{
	switch (ability)
	{
	case "ShockShort":
		CreateInventory(class'Arena.Ab_ShockShort', true);
		break;
		
	case "ShockMedium":
		CreateInventory(class'Arena.Ab_ShockMedium', true);
		break;
		
	case "ShockLong":
		CreateInventory(class'Arena.Ab_ShockLong', true);
		break;
		
	case "LightningBolt":
		CreateInventory(class'Arena.Ab_LightningBolt', true);
		break;
		
	case "EMP":
		CreateInventory(class'Arena.Ab_EMP', true);
		break;
		
	case "RangedEMP":
		CreateInventory(class'Arena.Ab_RangedEMP', true);
		break;
		
	case "Pedestal":
		CreateInventory(class'Arena.Ab_Pedestal', true);
		break;
	
	case "RockWall":
		CreateInventory(class'Arena.Ab_RockWall', true);
		break;
	
	case "StoneSlab":
		CreateInventory(class'Arena.Ab_StoneSlab', true);
		break;
		
	case "Bubble":
		CreateInventory(class'Arena.Ab_Bubble', true);
		break;
		
	case "ChargedShock":
		CreateInventory(class'Arena.Ab_ChargedShock', true);
		break;
		
	case "Deflection":
		CreateInventory(class'Arena.Ab_Deflection', true);
		break;
		
	case "DoubleBubble":
		CreateInventory(class'Arena.Ab_DoubleBubble', true);
		break;
		
	case "ElectromagneticField":
		CreateInventory(class'Arena.Ab_ElectromagneticField', true);
		break;
		
	case "FlashOfLightning":
		CreateInventory(class'Arena.Ab_FlashOfLightning', true);
		break;
		
	case "Osmosis":
		CreateInventory(class'Arena.Ab_Osmosis', true);
		break;
		
	case "Repulsion":
		CreateInventory(class'Arena.Ab_Repulsion', true);
		break;
		
	case "Magnetism":
		CreateInventory(class'Arena.Ab_Magnetism', true);
		break;
		
	case "ShotsOfHaste":
		CreateInventory(class'Arena.Ab_ShotsOfHaste', true);
		break;
		
	case "StoneFlesh":
		CreateInventory(class'Arena.Ab_StoneFlesh', true);
		break;
		
	case "SoundOfThunder":
		CreateInventory(class'Arena.Ab_TheSoundOfThunder', true);
		break;
		
	case "ThunderRush":
		CreateInventory(class'Arena.Ab_ThunderRush', true);
		break;
	
	case "Sand":
		CreateInventory(class'Arena.Ab_Sand', true);
		break;
		
	case "All":
	case "all":
		CreateInventory(class'Arena.Ab_ShockShort', true);
		CreateInventory(class'Arena.Ab_ShockMedium', true);
		CreateInventory(class'Arena.Ab_ShockLong', true);
		CreateInventory(class'Arena.Ab_LightningBolt', true);
		CreateInventory(class'Arena.Ab_EMP', true);
		CreateInventory(class'Arena.Ab_RangedEMP', true);
		CreateInventory(class'Arena.Ab_Pedestal', true);
		CreateInventory(class'Arena.Ab_RockWall', true);
		CreateInventory(class'Arena.Ab_StoneSlab', true);
		CreateInventory(class'Arena.Ab_Bubble', true);
		CreateInventory(class'Arena.Ab_ChargedShock', true);
		CreateInventory(class'Arena.Ab_Deflection', true);
		CreateInventory(class'Arena.Ab_DoubleBubble', true);
		CreateInventory(class'Arena.Ab_ElectromagneticField', true);
		CreateInventory(class'Arena.Ab_FlashOfLightning', true);
		CreateInventory(class'Arena.Ab_Repulsion', true);
		CreateInventory(class'Arena.Ab_Magnetism', true);
		CreateInventory(class'Arena.Ab_ShotsOfHaste', true);
		CreateInventory(class'Arena.Ab_StoneFlesh', true);
		CreateInventory(class'Arena.Ab_TheSoundOfThunder', true);
		CreateInventory(class'Arena.Ab_ThunderRush', true);
		CreateInventory(class'Arena.Ab_Osmosis', true);
		CreateInventory(class'Arena.Ab_Sand', true);
		break;
	}
}

exec function GiveStatus(string status)
{
	local class<StatusEffect> c;
	local StatusEffect se;
	
	switch (status)
	{
	case "Electrocuted":
		c = class'Arena.SE_Electrocuted';
		break;
	case "Flashed":
		c = class'Arena.SE_Flash';
		break;
		
	case "Blinded":
		c = class'Arena.SE_Blind';
		break;
	}
	
	if (c != None)
	{
		se = Spawn(c, None);
		se.Affector = ArenaPlayerController(self.Owner);
		se.Affectee = ArenaPlayerController(self.Owner);
		
		AddEffect(se);
	}
}

exec function GiveAmmo()
{
	if (ArenaWeapon(Weapon) != None)
		ArenaWeapon(Weapon).AddMaxAmmo();
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
		bOnlyOwnerSee=true
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
	
	Begin Object Class=RainCylinder Name=RC
	End Object
	//RainCylinder=RC
	//Components.Add(RC)
	
	IdleCamAnim=CameraAnim'CameraAssets.Animations.IdleAnimation'
	WalkCamAnim=CameraAnim'CameraAssets.Animations.WalkAnimation'
	
	bScriptTickSpecial=true
	RecoilControlName=RecoilNode
	LeftArmControlName=LeftArmNode
	ArmsTranslation=(X=-5,Y=-2,Z=45)
}