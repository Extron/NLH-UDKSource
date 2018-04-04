/*******************************************************************************
	Wp_BeamRifle

	Creation date: 18/04/2014 13:24
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_BeamRifle extends ArenaWeaponBase;

/**
 * The beam particle template to use to draw the beam.
 */
var ParticleSystem BeamTemplate;

/**
 * The actual beam particle system.
 */
var UDKParticleSystemComponent Beam;

/**
 * The beam spark particle template.
 */
var ParticleSystem SparksTemplate;

/**
 * The spark particles to emit at the beam target location.
 */
var ParticleSystemComponent Sparks;

/**
 * The animation node to blend the animation state of the beam rifle.
 */
var AN_BlendByState BlendStateNode;

/**
 * The actual sequence node for the firing animation.
 */
var AnimNodeSequence FireAnimNode;

/**
 * The actual sequence node for the overheat animation.
 */
var AnimNodeSequence OverheatAnimNode;

/**
 * The sound to play when the beam is active.
 */
var SoundCue BeamHumSC;

/**
 * The sound effect to play when turning on the beam.
 */
var SoundCue BeamStartSC;

/**
 * The sound effect to play when shutting off the beam.
 */
var SoundCue BeamStopSC;

/**
 * The sound effect to play when the beam rifle overheats.
 */
var SoundCue BeamOverheatSC;

/**
 * The audio component for the beam's humming sound.
 */
var AudioComponent BeamHum;

/**
 * The current source location for the beam.
 */
var vector Source;

/**
 * The current location the beam is hitting.
 */
var vector Target;

/**
 * Indicates that we are currently firing the beam.
 */
var bool FiringBeam;


simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	super.PostInitAnimTree(SkelComp);
	
	if (SkelComp == Mesh)
	{
		BlendStateNode = AN_BlendByState(SkelComp.FindAnimNode('BlendByState'));
		FireAnimNode = AnimNodeSequence(SkelComp.FindAnimNode('Fire'));
		OverheatAnimNode = AnimNodeSequence(SkelComp.FindAnimNode('Overheat'));
	}
	
	if (BlendStateNode != None)
		BlendStateNode.SetState("Idle");
}

simulated function StopFire(byte fireModeNum)
{
	super.StopFire(fireModeNum);
	
	KillBeam();
	FiringBeam = false;

	if (BlendStateNode != None && !Overheated)
	{
		BlendStateNode.BlendTime = 0.25;
		BlendStateNode.SetState("Idle");
	}
}

simulated function CustomFire()
{
	local array<ImpactInfo>	ImpactList;
	local ImpactInfo impact;
	local rotator sourceRot;
	local int i;
	
	GetMuzzleSocketLocRot(Source, sourceRot);
		
	impact = CalcWeaponFire(Source, Source +  vector(GetAdjustedAim(Source)) * GetTraceRange(), ImpactList);

	Target = impact.HitLocation;
	
	if (!FiringBeam && !Overheated)
	{
		StartBeam();
		FiringBeam = true;
		
		if (BlendStateNode != None)
		{
			if (FireAnimNode != None)
				FireAnimNode.SetPosition(0.0, true);
			
			BlendStateNode.BlendTime = 0.0;
			BlendStateNode.SetState("Fire");
		}
	}
	
	if (Beam != None)
		Beam.SetVectorParameter('BeamTarget', VSize(Target - Source) * vect(1, 0, 0));
		
	if (Sparks != None)
		Sparks.SetTranslation(VSize(Target - Source) * vect(1, 0, 0));
			
	SweepBullet(Source, Normal(Target - Source), SweepExtent, FMin(SweepRange, VSize(Target - Source)));

	if (ArenaPawn(Instigator) != None)
		InstantHitDamage[0] = ArenaPawn(Instigator).Stats.GetDamageGiven(BaseDamage * Stats.GetDamageModifier(), InstantHitDamageTypes[0]);
	
	for (i = 0; i < ImpactList.Length; i++)
		ProcessInstantHit(CurrentFireMode, ImpactList[i]);
}

simulated function Tick(float dt)
{
	local array<ImpactInfo>	ImpactList;
	local ImpactInfo impact;
	local rotator sourceRot;
	
	super.Tick(dt);
	
	if (FiringBeam)
	{
		GetMuzzleSocketLocRot(Source, sourceRot);
		impact = CalcWeaponFire(Source, Source +  vector(GetAdjustedAim(Source)) * GetTraceRange(), ImpactList);

		Target = impact.HitLocation;
	
		if (Beam != None)
			Beam.SetVectorParameter('BeamTarget', VSize(Target - Source) * vect(1, 0, 0));
			
		if (Sparks != None)
			Sparks.SetTranslation(VSize(Target - Source) * vect(1, 0, 0));
	}
}

simulated function rotator AddSpread(rotator BaseAim)
{
	return BaseAim;
}

simulated function Overheat()
{
	KillBeam();
	FiringBeam = false;
	
	if (BeamOverheatSC != None)
		WeaponPlaySound(BeamOverheatSC);
		
	if (BlendStateNode != None)
	{		
		if (OverheatAnimNode != None)
			OverheatAnimNode.SetPosition(0.0, true);
				
		BlendStateNode.BlendTime = 0.05;
		BlendStateNode.SetState("Overheat");
	}
}

simulated function CoolDown()
{
	if (BlendStateNode != None)
	{
		BlendStateNode.BlendTime = 0.25;
		BlendStateNode.SetState("Idle");
	}
}

simulated function StartBeam()
{
	if (Overheated)
		return;
		
	if (BeamTemplate != None && Beam == None)
	{
		Beam = new(self) class'UDKParticleSystemComponent';
		Beam.bAutoActivate = true;
		Beam.SetTemplate(BeamTemplate);
		Beam.SetAbsolute(false, false, false);
		Beam.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		Beam.bUpdateComponentInTick = true;
		Beam.SetTickGroup( TG_EffectsUpdateWork );
		Beam.SetVectorParameter('BeamTarget', VSize(Target - Source) * vect(1, 0, 0));
		Beam.SetTranslation(vect(-10, 0, 0));
		AttachToMuzzleSocket(Beam);
	}
	else if (Beam != None)
	{
		Beam.SetHidden(false);
		Beam.ActivateSystem();
	}
	
	if (Sparks == None)
	{	
		Sparks = new(self) class'ParticleSystemComponent';
		Sparks.bAutoActivate = true;
		Sparks.SetTemplate(SparksTemplate);
		Sparks.SetAbsolute(false, false, false);
		Sparks.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		Sparks.bUpdateComponentInTick = true;
		Sparks.SetTickGroup( TG_PostUpdateWork );
		Sparks.SetVectorParameter('BeamTarget', VSize(Target - Source) * vect(1, 0, 0));
		Sparks.SetTranslation(VSize(Target - Source) * vect(1, 0, 0));
		
		AttachToMuzzleSocket(Sparks);
	}
	else
	{
		Sparks.ActivateSystem();
	}
	
	if (BeamHum == None)
	{
		BeamHum = new(self) class'AudioComponent';
		BeamHum.SoundCue = BeamHumSC;
		BeamHum.bAutoPlay = false;
		AttachComponent(BeamHum);
	}
	
	if (BeamHum != None)
		BeamHum.Play();
		
	if (BeamStartSC != None)
		WeaponPlaySound(BeamStartSC);
}

simulated function KillBeam()
{
	if (Overheated || !FiringBeam)
		return;
	
	if (Beam != None)
	{
		Beam.SetHidden(true);
		Beam.DeactivateSystem();
	}
	
	if (Sparks != None)
		Sparks.DeactivateSystem();
		
	if (BeamHum != None)
		BeamHum.Stop();
		
	if (BeamStopSC != None)
		WeaponPlaySound(BeamStopSC);
}

defaultproperties
{
	Begin Object Name=FirstPersonMesh
		SkeletalMesh=SkeletalMesh'BeamRifles.Meshes.BeamRifle1'
		PhysicsAsset=PhysicsAsset'BeamRifles.Meshes.BeamRifle1_Physics'
		AnimSets[0]=AnimSet'BeamRifles.Animations.BR1Animations'
		AnimTreeTemplate=AnimTree'BeamRifles.Animations.BR1AnimationTree'
	End Object
	
	Begin Object Name=NewStats
		Values[WSVWeight]=4
		Values[WSVStability]=1
		Values[WSVRateOfFire]=0.1
		Values[WSVDamageOutput]=0.85
		Values[WSVHeatCost]=25
		Values[WSVCoolDownRate]=100
		Values[WSVOverheatDelay]=1.5
	End Object
	
	DefaultComponents[WCStock]=class'Arena.Wp_S_CheapStock'
	DefaultComponents[WCBarrel]=class'Arena.Wp_B_SpinningBarrel'
	DefaultComponents[WCMuzzle]=class'Arena.Wp_M_NoMuzzle'
	DefaultComponents[WCOptics]=class'Arena.Wp_O_NoOptics'
	DefaultComponents[WCUnderAttachment]=class'Arena.Wp_UA_NoUnderAttachment'
	DefaultComponents[WCSideAttachment]=class'Arena.Wp_SA_NoSideAttachment'
	
	CriticalTemperature=500
	
	//PlayerAnimSet=AnimSet'AC_Player.Animations.CheapRifleMovementAnimations'
	BeamTemplate=ParticleSystem'BeamRifles.Particles.Beam1ParticleSystem'
	SparksTemplate=ParticleSystem'BeamRifles.Particles.Beam1SparkParticleSystem'
	
	WeaponFireTypes[0]=EWFT_Custom
	InstantHitDamageTypes[0]=class'Arena.Dmg_Beam'
	InstantHitMomentum[0]=100
	AllowedFireModes[0]=FMBeam
	FireModes[0]=FMBeam
	Mode=0
	CycleTime=0.25
	BurstCount=3
	
	//FireSound=SoundCue'BasicRifleBase.Audio.GunshotSC'
	BeamHumSC=SoundCue'BeamRifles.Audio.BeamHumSC'
	BeamStopSC=SoundCue'BeamRifles.Audio.BeamStopSC'
	BeamStartSC=SoundCue'BeamRifles.Audio.BeamStartSC'
	BeamOverheatSC=SoundCue'BeamRifles.Audio.BeamOverheatSC'
	
	FireAnims[0]=Fire
	//EquipAnims[0]=CheapRifleTakeOut
	//PlayerAnimSet=AnimSet'AC_Player.Animations.PlayerAnim'
	
	WeaponRange=100000
	
	ViewOffset=(X=45, Y=5, Z=-22);
	BaseName="Beam Rifle Base"
	BaseDescription="Essentially a portable particle accelerator, beam rifles are very rare, only found in deep ruins of the ancient world."
	Type=WTBeamRifle
	Size=WSRegular
	MaxAmmo=1000
	MaxClip=1000
	Ammo=1000
	Clip=1000
	BaseDamage=50
}