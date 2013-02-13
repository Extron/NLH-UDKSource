/******************************************************************************
	Ab_BubbleShield
	
	Creation date: 30/01/2013 16:40
	Copyright (c) 2013, Zack Diller
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
******************************************************************************/

/**
 * An actor used to represent the magnetic deflection shield for the Bubble ability.
 */
class Ab_BubbleShield extends Actor;


/* The template to use for the particles of the shield. */
var ParticleSystem ShieldTemplate;

/* The shield's particle instance. */
var ParticleSystemComponent Shield;

/** The mesh used to draw the component. */
var() editinline MeshComponent Mesh;

/* This is the variable the stores the time the bubble has left before it expires. */
var float ShieldTimer;

/* The amount of damage the shield reduces enemy bullets & beams by. */
var float DamageReduction;

/* PlayerStatsModifier for altering damage taken by weapons why holding a bubble */
var PlayerStatModifier playerStatMod;

simulated function PostBeginPlay()
{
	`log("Shield spawned");
	super.PostBeginPlay();
	
	SetHidden(false);
	Mesh.SetLightEnvironment(ArenaPawn(Instigator).LightEnvironment);
	AttachComponent(Mesh);
	
	EmitShield();
	
	/* if (ArenaPawn(Instigator) != None)
	{
		// ERROR: Makes the player invicible
		ArenaPawn(Instigator).Stats.SetTypeDamageInput(class 'Arena.Dmg_LightBeam', DamageReduction);
	} */
	
	// Makes it so the player takes less damage from light beams
	playerStatMod.SetTypeDamageInputMod(class 'Arena.Dmg_LightBeam', DamageReduction);
	
	if (ArenaPawn(Instigator) != None)
	{
		// ERROR: Makes the player invicible
		ArenaPawn(Instigator).Stats.AddModifier(PlayerStatMod);
	}
	
	SetTimer(ShieldTimer, false, 'DestroyShield');
}

simulated function Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	super.Touch(Other, OtherComp, HitLocation, HitNormal);
	
	if (RifleBullet(Other) != None)
	{
		`log("Decreasing Bullet Damage");
		
		RifleBullet(Other).Damage = (RifleBullet(Other).Damage) * DamageReduction;
	}
}

simulated function Tick(float dt)
{
	if (ArenaPawn(Instigator) != None)
	{
		SetLocation(Instigator.Location);
	}

	//ShieldTimer = ShieldTimer - dt;
	
	if (ShieldTimer <= 0) {
		self.Destroy();
		// Undo the damage mod
		//ArenaPawn(Instigator).Stats.SetTypeDamageInput(class 'Arena.Dmg_LightBeam', 1.0);
		`log("Bubble shield expired");
	}
	
	super.Tick(dt);
}

simulated function bool StopsProjectile(Projectile P)
{
	return false;
}

simulated function DestroyShield()
{
	`log("Bubble shield expired");
	
	if (ArenaPawn(Instigator) != None)
	{
		// ERROR: Makes the player invicible
		ArenaPawn(Instigator).Stats.RemoveModifier(PlayerStatMod);
	}
	
	self.Destroy();	
}

/**
 * Emits the shield's particle system into the world.
 */
simulated function EmitShield()
{
	if (WorldInfo.NetMode != NM_DedicatedServer && ShieldTemplate != None && ArenaPawn(Owner) != None)
	{
		Shield = WorldInfo.MyEmitterPool.SpawnEmitter(ShieldTemplate, vect(0, 0, 0));
		Shield.SetAbsolute(false, false, false);
		Shield.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		Shield.bUpdateComponentInTick = true;
		AttachComponent(Shield);
	}
}

defaultproperties
{
	bCollideActors=true
	bBlockActors=true
	
	Begin Object Class=StaticMeshComponent Name=ShieldMesh
		StaticMesh=StaticMesh'ArenaAbilities.Meshes.BubbleShieldMesh'
		DepthPriorityGroup=SDPG_PostProcess
		bOnlyOwnerSee=false
		bCastDynamicShadow=false
		CastShadow=false
		Scale=3
	End Object
	Mesh=ShieldMesh
	
	Begin Object Class=PlayerStatModifier Name=NewMod
	End Object
	playerStatMod=NewMod
	
	ShieldTimer=15.0
	DamageReduction=0.85
}