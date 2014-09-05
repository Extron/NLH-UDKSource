/*******************************************************************************
	SE_Heal

	Creation date: 31/08/2014 10:43
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class SE_Heal extends StatusEffect;

/**
 * The template to use for the water stream particles.
 */
var ParticleSystem WaterStreamTemplate;

/**
 * The template to use for the healing glow particles.
 */
var ParticleSystem HealingGlowTemplate;

/**
 * The particle systems for the streams of water.
 */
var array<ParticleSystemComponent> WaterStreams;

/**
 * The healing glow to surround the affectee with.
 */
var ParticleSystemComponent HealingGlow;

/**
 * The maximum amount of health that the affectee should gain.
 */
var float MaxHealthInrcease;

/**
 * The height that the particles should swirl to.
 */
var float HPSwirlHeight;

/**
 * The radius that the particles should swirl to.
 */
var float HPSwirlRadius;

/**
 * The rate at which the height of the water streams should vary.
 */
var float HPHeightRate;

/**
 * The rate at which the water streams should swirl around the affectee.
 */
var float HPSwirlRate;

/**
 * The number of streams of water to wrap around the affectee.
 */
var int NumWaterStreams;


simulated function Tick(float dt)
{
	local vector position;
	local float theta, phi;
	local int i;
	
	super.Tick(dt);
	
	for (i = 0; i < WaterStreams.Length; i++)
	{
		theta = HPSwirlRate * 2 * Pi * Counter;
		phi = 2 * Pi * i / WaterStreams.Length;
		
		if (i % 2 == 1) theta = -theta;
		
		position.x = HPSwirlRadius *(Cos(theta) * Cos(phi) - Sin(theta) * Sin(phi));
		position.y = HPSwirlRadius *(Sin(theta) * Cos(phi) + Cos(theta) * Sin(phi));
		position.z = HPSwirlHeight * Cos(HPHeightRate * 2 * Pi * Counter) ** 2;
	
		WaterStreams[i].SetTranslation(position);
	}
	
	Affectee.HealDamage(int(MaxHealthInrcease * dt / Duration), Instigator.Controller, class'Arena.Dmg_Healing');
}

simulated function ActivateEffect(Actor target)
{
	super.ActivateEffect(target);
	
	if (ArenaPawn(target) != None)
	{
		if (ArenaPawn(target).PlayerReplicationInfo != None && ArenaPawn(target).PlayerReplicationInfo.Team != None)
		{
			if (ArenaPawn(target).PlayerReplicationInfo.Team.TeamIndex != ArenaPawn(Instigator).PlayerReplicationInfo.Team.TeamIndex)
			{
				DeactivateEffect();
				return;
			}
		}
		
		ArenaPawn(target).GetBoundingCylinder(HPSwirlRadius, HPSwirlHeight);
		EmitParticles();
	}
}

simulated function DeactivateEffect()
{
	local int i;
	
	for (i = 0; i < WaterStreams.Length; i++)
	{
		if (WaterStreams[i] != None)
		{
			WaterStreams[i].DeactivateSystem();
			
			Affectee.DetachComponent(WaterStreams[i]);
			
			WaterStreams[i] = None;
		}
	}
	
	if (HealingGlow != None)
	{
		HealingGlow.DeactivateSystem();
			
		Affectee.DetachComponent(HealingGlow);
		
		HealingGlow = None;
	}
	
	WaterStreams.Length = 0;
	
	super.DeactivateEffect();
}

simulated function EmitParticles()
{
	local int i;
	
	if (WorldInfo.NetMode != NM_DedicatedServer && WaterStreamTemplate != None)
	{
		for (i = 0; i < NumWaterStreams; i++)
		{
			WaterStreams[i] = new class'ParticleSystemComponent';
			
			Affectee.AttachComponent(WaterStreams[i]);
			
			WaterStreams[i].SetTemplate(WaterStreamTemplate);
			WaterStreams[i].bAutoActivate = false;
			WaterStreams[i].SetAbsolute(false, false, false);
			WaterStreams[i].SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
			WaterStreams[i].bUpdateComponentInTick = true;
					
			WaterStreams[i].ActivateSystem();
		}
		
		HealingGlow = new class'ParticleSystemComponent';
			
		Affectee.AttachComponent(HealingGlow);
		
		HealingGlow.SetTemplate(HealingGlowTemplate);
		HealingGlow.bAutoActivate = false;
		HealingGlow.SetAbsolute(false, false, false);
		HealingGlow.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		HealingGlow.bUpdateComponentInTick = true;
				
		HealingGlow.ActivateSystem();
	}
}

defaultproperties
{
	Begin Object Name=NewStatMod
	End Object
	
	DisplayColor=0xFFFFFF
	
	EffectName="Healed"
	Duration=7.5
	Group=EG_Water
	WaterStreamTemplate=ParticleSystem'Lamentia.Particles.WaterStreamPS'
	HealingGlowTemplate=ParticleSystem'Lamentia.Particles.HealingGlowPS'
	
	HPSwirlHeight=128
	HPSwirlRadius=64
	HPSwirlRate=1
	HPHeightRate=0.25
	NumWaterStreams=4
	//Explosions[0]=(Trigger=class'Arena.Dmg_Water',ExplosionType=class'Arena.ElectricExplosion')
}