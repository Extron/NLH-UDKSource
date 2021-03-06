/*******************************************************************************
	ArenaWeaponComponent

	Creation date: 24/08/2012 13:51
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaWeaponComponent extends Actor
	dependson(WeaponStats, ArenaWeapon);


/** Stores what type of weapon base types this attachment can be used with. */
var(Weapon) array<WeaponType> CompatibleTypes;

/** Stores what type of weapon base sizes this attachment can be used with. */
var(Weapon) array<WeaponSize> CompatibleSizes;

/**
 * A list of all the valid subclasses of this component.
 */
var array<class<ArenaWeaponComponent> > Subclasses;

/** 
 * The mesh used to draw the component. 
 */
var() editinline MeshComponent Mesh;

/**
 * The base that this component is currently attached to.
 */
var ArenaWeaponBase WeaponBase;

/** The stat modifier of the component. */
var WeaponStatModifier StatMod;

/** The animation to play on the component when the weapon is fired. */
var name FireAnim;

/** The name of the weapon component. */
var string ComponentName;

/** A description of the component, used for menu interfaces. */
var string ComponentDescription;

/**
 * The icon for the component to use in the GUI.
 */
var string ComponentIcon;

/** The numeric weight of the component. */
var float Weight;

/** The cost in energy that this attachment takes up. */
var float EnergyCost;

/** The name of the socket that attaches to the main weapon base. */
var name AttachSock;

/**
 * The cost of the component in tokens.
 */
var int Cost;

simulated function StartFire()
{
}

simulated function StopFire()
{
}

/**
 * Attaches this component to a weapon base.
 *
 * @param weap - The weapon base to attach to.
 * @param socket - The socket on the base to attach to.
 */
simulated function AttachToBase(ArenaWeaponBase weap, name socket)
{
	local ArenaPawn pawn;
	local SkeletalMeshSocket weaponSocket;
	local vector scale;
	
	pawn = ArenaPawn(weap.Instigator);
	
	weaponSocket = SkeletalMeshComponent(weap.Mesh).GetSocketByName(socket);
	
	if (weaponSocket != None)
	{
		SetBase(weap.Mesh.Owner, , SkeletalMeshComponent(weap.Mesh), socket);
		scale = weaponSocket.RelativeScale * pawn.GetWeaponHandSocketScale();
	}
	
	AttachComponent(Mesh);
	SetHidden(false);
	Mesh.SetScale3D(scale);
	
	WeaponBase = weap;
	
	weap.Stats.Values[WSVWeight] += Weight;
	weap.Stats.AddModifier(StatMod);
}

simulated function AttachToBaseSpecial(ArenaWeaponBase weap, name socket, LightEnvironmentComponent lightEnv)
{
	if (SkeletalMeshComponent(weap.Mesh).GetSocketByName(socket) != None)
	{		
		`log(self @ "Weapon Owner" @ weap.Owner);
		SetBase(weap, , SkeletalMeshComponent(weap.Mesh), socket);
	}
	
	AttachComponent(Mesh);
	SetHidden(false);
	Mesh.SetLightEnvironment(lightEnv);
	
	weap.Stats.Values[WSVWeight] += Weight;
	weap.Stats.AddModifier(StatMod);
}


/**
 * Processes any logic needed for the component when the weapon fires.
 */
simulated function FireWeapon()
{
	PlayAnimation(FireAnim, 0);
}

/**
 * Play an animation on the weapon component mesh
 * Network: Local Player and clients
 *
 * @param sequence - Animation sequence to play on the weapon component's skeletal mesh.
 * @param duration - The desired duration, in seconds, the animation should be played.
 */
simulated function PlayAnimation(name sequence, float duration, optional bool loop, optional SkeletalMeshComponent skelMesh)
{
	local AnimNodeSequence weapNode;
	local AnimTree tree;

	if( WorldInfo.NetMode == NM_DedicatedServer )
	{
		return;
	}

	if (skelMesh == None)
	{
		skelMesh = SkeletalMeshComponent(Mesh);
	}

	if( skelMesh == None || GetAnimNodeSeq() == None )
	{
		return;
	}

	if(duration > 0.0)
	{
		skelMesh.PlayAnim(Sequence, duration, loop);
	}
	else
	{
		tree = AnimTree(skelMesh.Animations);
		
		if (tree != None)
		{
			weapNode = AnimNodeSequence(tree.Children[0].Anim);
		}
		else
		{
			weapNode = AnimNodeSequence(skelMesh.Animations);
		}

		weapNode.SetAnim(Sequence);
		weapNode.PlayAnim(loop, skelMesh.GetAnimLength(sequence));
	}
}

simulated function AnimNodeSequence GetAnimNodeSeq()
{
	local AnimTree Tree;
	local AnimNodeSequence AnimSeq;
	local SkeletalMeshComponent SkelMesh;

	SkelMesh = SkeletalMeshComponent(Mesh);
	if(SkelMesh != None)
	{
		Tree = AnimTree(SkelMesh.Animations);
		if (Tree != None)
		{
			AnimSeq = AnimNodeSequence(Tree.Children[0].Anim);
		}
		else
		{
			AnimSeq = AnimNodeSequence(SkelMesh.Animations);
		}

		return AnimSeq;
	}

	return None;
}

simulated function bool CanAttachToBase(ArenaWeaponBase weap)
{
	return CompatibleTypes.Find(weap.Type) > -1 && CompatibleSizes.Find(weap.Size) > -1 && EnergyCost + weap.GetEnergyUsed() <= weap.EnergyMax;
}

simulated function SetComponentFOV(float angle)
{
	UDKSkeletalMeshComponent(Mesh).SetFOV(angle);
}

simulated function SetWeaponScale(float scale)
{
	Mesh.SetScale(scale);
}

simulated function SetDepthPriorityGroup(ESceneDepthPriorityGroup group)
{
	Mesh.SetDepthPriorityGroup(group);
}

/**
 * Allows interactivity to be programmed into attachments.  This function is called when the player presses the designated toggle button.
 */
simulated function Toggle()
{
}

defaultproperties
{
	Begin Object Class=UDKSkeletalMeshComponent Name=FirstPersonMesh
		DepthPriorityGroup=SDPG_PostProcess
		bOnlyOwnerSee=false
		bOverrideAttachmentOwnerVisibility=true
		bCastDynamicShadow=false
		CastShadow=false
		bOwnerNoSee=false
	End Object
	Mesh=FirstPersonMesh
	
	Begin Object Class=WeaponStatModifier Name=NewStatMod
	End Object
	StatMod=NewStatMod
}