/*******************************************************************************
	AP_Player

	Creation date: 12/01/2013 22:03
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class AP_Player extends ArenaPawn;


/**
 * The list of armor that the player is wearing.
 */
var array<ArmorComponent> Armor;

/**
 * The sound cue to play when the player is near death.
 */
var AudioComponent NearDeathHeartbeat;

/**
 * The right arm used for first person animations are kept separate from the rest of the 
 * pawn's mesh for simplicity.
 */
var SkeletalMeshComponent RightArm;

/**
 * The left arm used for first person animations are kept separate from the rest of the 
 * pawn's mesh for simplicity.
 */
var SkeletalMeshComponent LeftArm;

/**
 * The arm control for the left hand, to place on the weapon.
 */
var SkelControlLimb LeftArmControl;

/**
 * The name of the left arm animation control.
 */
var name LeftArmControlName;

/**
 * The translation to apply to the armor when drawing them.
 */
var vector ArmorTranslation;

simulated event TickSpecial(float dt)
{
	local vector gripLoc;
	local rotator gripRot;
	
	super.TickSpecial(dt);
	
	if (ArenaWeapon(Weapon) != None)
	{
		ArenaWeapon(Weapon).GetGripSocketLocRot(gripLoc, gripRot);
		//LeftArmControl.EffectorLocation = gripLoc;
	}
	
	if (NearDeathHeartbeat != None)
	{
		if (Health < HealthMax / 4 && !NearDeathHeartbeat.IsPlaying() && !NearDeathHeartbeat.IsFadingIn())
			NearDeathHeartbeat.FadeIn(0.05, 1.0);
		else if (Health >= HealthMax / 4 && NearDeathHeartbeat.IsPlaying() && !NearDeathHeartbeat.IsFadingOut())
			NearDeathHeartbeat.FadeOut(0.05, 0.0);
	}
		
}

function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{	
	if (NearDeathHeartbeat != None)
		NearDeathHeartbeat.Stop();
		
	return super.Died(Killer, DamageType, HitLocation);
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	local AN_BlendBySprint node;

	super.PostInitAnimTree(SkelComp);

	if (SkelComp == RightArm)
	{
		RecoilControl = GameSkelCtrl_Recoil(RightArm.FindSkelControl(RecoilControlName));
		
		foreach RightArm.AllAnimNodes(class'AN_BlendBySprint', node)
		{
			node.SetSprint(false);
			SprintAnimNodes.AddItem(node);
		}
	}
	if (SkelComp == LeftArm)
	{
		LeftArmControl = SkelControlLimb(LeftArm.FindSkelControl(LeftArmControlName));
		LeftArmControl.ControlStrength = 0.0;
		
		EnableLeftHandPositioning(false);
		
		foreach LeftArm.AllAnimNodes(class'AN_BlendBySprint', node)
		{
			node.SetSprint(false);
			SprintAnimNodes.AddItem(node);
		}
	}
}

function InitInventory()
{
	local ArenaWeapon newWeapon;
	local ArmorComponent armorComponent;
	local int i;
	
	super.InitInventory();

	if (ArenaPlayerController(Controller) != None && ArenaPlayerController(Controller).Loadout != None && ArenaPlayerController(Controller).Loadout.PrimaryWeapon != None)
	{
		newWeapon = CreateWeapon(ArenaPlayerController(Controller).Loadout.PrimaryWeapon);
	}
	
	if (ArenaPlayerController(Controller) != None && ArenaPlayerController(Controller).Loadout != None && ArenaPlayerController(Controller).Loadout.Armor != None)
	{
		for (i = 0; i < ArenaPlayerController(Controller).Loadout.Armor.Components.Length; i++)
		{
			armorComponent = Spawn(ArenaPlayerController(Controller).Loadout.Armor.Components[i], self);
			armorComponent.MeshComponent.SetLightEnvironment(LightEnvironment);
			`log("Adding armor component" @ armorComponent);
			AttachArmor(armorComponent);
		}
	}
	
	if (ArenaInventoryManager(InvManager) != None)
	{	
		if (newWeapon != None)
		{
			InvManager.AddInventory(newWeapon);
			InvManager.NextWeapon();
			ArenaPlayerController(Controller).SetWeaponFOV();
		}
		
		for (i = 0; i < ArenaPlayerController(Controller).Loadout.Abilities.Length; i++)
		{
			CreateInventory(ArenaPlayerController(Controller).Loadout.Abilities[i], true);
		}
		
		ArenaInventoryManager(InvManager).NextAbility();
	}
}

function bool DoJump(bool bUpdating)
{
	local bool ret;
	
	ret = super.DoJump(bUpdating);
	
	PlayArmAnimation('Arms1PJump');
	
	return ret;
}

event Landed(vector HitNormal, Actor FloorActor)
{
	super.Landed(HitNormal, FloorActor);
	
	PlayArmAnimation('Arms1PLand');
}

simulated function Melee()
{
	local int anim;
	local float duration;
	
	anim = Rand(ArenaWeapon(Weapon).MeleeAnims.Length);
	
	`log("Trying to melee" @ Meleeing);
	
	if (!Meleeing)
	{
		`log("Meleeing");
		
		PlayArmAnimation(ArenaWeapon(Weapon).MeleeAnims[anim]);
		
		duration = RightArm.GetAnimLength(ArenaWeapon(Weapon).MeleeAnims[anim]);
		`log("Duration" @ duration);
		
		SetTimer(duration, false, 'ResetMelee');
	}
	
	super.Melee();
}

simulated function ResetMelee()
{
	`log("Resetting melee");
	
	Meleeing = false;
}

/**
 * Gets the location that abilities will fire from.  Preferrably, this will be the location of the
 * player's right or left hand (as per player handedness).
 */
function GetAbilitySourceOffset(out vector l, out rotator r)
{	
	if (RightArm.GetSocketByName('AbilitySourceSocket') != None)
		RightArm.GetSocketWorldLocationAndRotation('AbilitySourceSocket', l, r, 0);
	else if (LeftArm.GetSocketByName('AbilitySourceSocket') != None)
		LeftArm.GetSocketWorldLocationAndRotation('AbilitySourceSocket', l, r, 0);
}

function GetWeaponSourceOffset(out vector l, out rotator r)
{	
	if (RightArm.GetSocketByName('HandSocket') != None)
		RightArm.GetSocketWorldLocationAndRotation('HandSocket', l, r, 0);
	else if (LeftArm.GetSocketByName('HandSocket') != None)
		LeftArm.GetSocketWorldLocationAndRotation('HandSocket', l, r, 0);
}

function AttachToAbilitySource(ActorComponent component)
{
	LeftArm.AttachComponentToSocket(component, GetAbilityHandSocket());
}

simulated function PositionArms()
{
	local rotator R;
	local int i;
	
	R = CurrentRecoil;
	
	if (Controller != None)
		R.Pitch += Controller.Rotation.Pitch;
	
	for (i = 0; i < Armor.Length; i++)
		Armor[i].MeshComponent.SetTranslation(ArmorTranslation);
	
	RightArm.SetTranslation(64.432 * (vect(0, 0, 1) - (vect(0, 0, 1) >> R)));
	RightArm.SetRotation(R);
	
	LeftArm.SetTranslation(64.432 * (vect(0, 0, 1) - (vect(0, 0, 1) >> R)));
	LeftArm.SetRotation(R);
}

simulated function PlayArmAnimation(name sequence, optional float duration, optional bool loop, optional SkeletalMeshComponent skelMesh)
{
	local AnimNodePlayCustomAnim node;

	if (WorldInfo.NetMode == NM_DedicatedServer || !IsFirstPerson())
		return;

		node = GetArmAnimNode(LeftArm);

		if (LeftArm == None || node == None)
			return;

		node.PlayCustomAnim(sequence, 1.0, , , loop);
		
		node = GetArmAnimNode(RightArm);

		if (LeftArm == None || node == None)
			return;

		node.PlayCustomAnim(sequence, 1.0, , , loop);
}

simulated function AnimNodePlayCustomAnim GetArmAnimNode(SkeletalMeshComponent skelMesh)
{
	if (skelMesh != None)
		return AnimNodePlayCustomAnim(AnimTree(skelMesh.Animations).Children[0].Anim);

	return None;
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

simulated function AttachArmor(ArmorComponent armorComponent)
{
	Armor.AddItem(armorComponent);
	
	AttachComponent(armorComponent.MeshComponent);
	AddStatMod(armorComponent.StatMod);
	
	if (armorComponent.Type == ACTRightArm)
		RightArm = armorComponent.MeshComponent;
	
	if (armorComponent.Type == ACTLeftArm)
		LeftArm = armorComponent.MeshComponent;
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
				
	case "Discharge":
		CreateInventory(class'Arena.Ab_Discharge', true);
		break;
						
	case "LightningStorm":
		CreateInventory(class'Arena.Ab_LightningStorm', true);
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
		
	case "DustCloud":
		CreateInventory(class'Arena.Ab_DustCloud', true);
		break;
		
	case "ElectromagneticField":
		CreateInventory(class'Arena.Ab_ElectromagneticField', true);
		break;
		
	case "FlashOfLightning":
		CreateInventory(class'Arena.Ab_FlashOfLightning', true);
		break;

	case "HeavyHanded":
		CreateInventory(class'Arena.Ab_HeavyHanded', true);
		break;

	case "Osmosis":
		CreateInventory(class'Arena.Ab_Osmosis', true);
		break;
		
	case "PortableShield":
		CreateInventory(class'Arena.Ab_PortableShield', true);
		break;
		
	case "Repulsion":
		CreateInventory(class'Arena.Ab_Repulsion', true);
		break;
		
	case "RockFist":
		CreateInventory(class'Arena.Ab_RockFist', true);
		break;
		
	case "Magnetism":
		CreateInventory(class'Arena.Ab_Magnetism', true);
		break;
	
	case "SandFlesh":
		CreateInventory(class'Arena.Ab_SandFlesh', true);
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
		
	case "Sandstorm":
		CreateInventory(class'Arena.Ab_Sandstorm', true);
		break;	
		
	case "WallLaunch":
		CreateInventory(class'Arena.Ab_WallLaunch', true);
		break;
		
	case "Earthquake":
		CreateInventory(class'Arena.Ab_Earthquake', true);
		break;
		
	case "TremblingEarth":
		CreateInventory(class'Arena.Ab_TremblingEarth', true);
		break;
		
	case "All":
	case "all":
		CreateInventory(class'Arena.Ab_ShockShort', true);
		CreateInventory(class'Arena.Ab_ShockMedium', true);
		CreateInventory(class'Arena.Ab_ShockLong', true);
		CreateInventory(class'Arena.Ab_LightningBolt', true);
		CreateInventory(class'Arena.Ab_Discharge', true);
		CreateInventory(class'Arena.Ab_LightningStorm', true);
		CreateInventory(class'Arena.Ab_EMP', true);
		CreateInventory(class'Arena.Ab_RangedEMP', true);
		CreateInventory(class'Arena.Ab_Pedestal', true);
		CreateInventory(class'Arena.Ab_RockWall', true);
		CreateInventory(class'Arena.Ab_StoneSlab', true);
		CreateInventory(class'Arena.Ab_PortableShield', true);
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
		CreateInventory(class'Arena.Ab_WallLaunch', true);
		CreateInventory(class'Arena.Ab_DustCloud', true);
		CreateInventory(class'Arena.Ab_Earthquake', true);
		CreateInventory(class'Arena.Ab_TremblingEarth', true);
		CreateInventory(class'Arena.Ab_SandFlesh', true);
		CreateInventory(class'Arena.Ab_HeavyHanded', true);
		CreateInventory(class'Arena.Ab_RockFist', true);
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
	Begin Object Class=AudioComponent Name=NDHB
		SoundCue=SoundCue'AC_Player.Audio.HeartbeatSC'
        bAutoPlay=false
	End Object
	Components.Add(NDHB)
	NearDeathHeartbeat=NDHB
	
	Begin Object Class=RainCylinder Name=RC
	End Object
	//RainCylinder=RC
	//Components.Add(RC)
	
	IdleCamAnim=CameraAnim'CameraAssets.Animations.IdleAnimation'
	WalkCamAnim=CameraAnim'CameraAssets.Animations.WalkAnimation'
	
	bScriptTickSpecial=true
	RecoilControlName=RecoilNode
	LeftArmControlName=LeftArmNode
	ArmorTranslation=(X=-15,Y=0,Z=0)
}