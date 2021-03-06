/*******************************************************************************
	Ab_LightningBolt

	Creation date: 15/05/2013 14:21
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Ab_LightningBolt extends ArenaAbility;

/**
 * Lightning bolt will spawn some dark clouds in the sky that the bolt will shoot from.  This is their particle template.
 */
var ParticleSystem CloudsTemplate;

/**
 * The actual clouds particle system.
 */
var ParticleSystemComponent Clouds;

/**
 * This measures the extent to which Lightning Bolt can auto target.  If it is 1, then it can only target objects 
 * directly in front of the player.  If it is 0, then it can target anything that is in front of the player, no matter
 * how far to the left or right they are wrt where the player is looking.
 */
var float Extent;

simulated function StartFireAnimation()
{
	EmitClouds();
}

simulated function InstantFire()
{
	local vector start, end;
	local Array<ImpactInfo>	impactList;
	local int i;
	local ImpactInfo impact;
	local Actor iter;
	local Actor attractor;
	
	attractor = None;
	
	// define range to use for CalcWeaponFire()
	start = Instigator.GetWeaponStartTraceLocation();
	end = (start + vector(GetAdjustedAim(start)) * GetTraceRange());
	
	foreach VisibleCollidingActors(class'Actor', iter, GetTraceRange(), start)
	{
		if (Normal(iter.Location - start) dot Normal(end - start) >= Extent)
		{
			if (IEnvObj(iter) != None)
			{
				if (IEnvObj(iter).HasProperty("Conductive") && (attractor == None || VSize(attractor.Location - start) > VSize(iter.Location - start)))
					attractor = iter;
			}
			else if (ArenaPawn(iter) != None && ArenaPawn(iter) != Instigator)
			{
				if (ArenaPawn(iter).IsConductive() && (attractor == None || VSize(attractor.Location - start) > VSize(iter.Location - start)))
					attractor = iter;
			}
		}
	}
	
	//`log("Attractor" @ attractor);
	
	if (attractor != None)
		impact = CalcWeaponFire(start, attractor.Location, impactList);
	else
		impact = CalcWeaponFire(start, end, impactList);
		
	if (Role == ROLE_Authority)
	{
		SetFlashLocation(impact.HitLocation);	
	}

	EmitIHBeam(impact.HitLocation);
	
	if (ArenaPawn(Instigator) != None)
		InstantHitDamage[0] = ArenaPawn(Instigator).Stats.GetDamageGiven(BaseDamage, InstantHitDamageTypes[0]);

	for (i = 0; i < impactList.Length; i++)
	{
		ProcessInstantHit(CurrentFireMode, impactList[i]);
	}
}

simulated function EmitIHBeam(vector hitLocation)
{
	local vector l;
	local rotator r;
	local vector traceLoc, traceNorm;
	
	if (WorldInfo.NetMode != NM_DedicatedServer && IHBeamTemplate != None)
	{
		if (ArenaPawn(Instigator) != None)
			ArenaPawn(Instigator).GetAbilitySourceOffset(l, r);// + SourceOffset) >> );r
		
		r = Instigator.Controller.Rotation;
		l = l + (SourceOffset >> r);

		if (Trace(traceLoc, traceNorm, l + vect(0, 0, 256), l) == None)
			traceLoc = l + vect(0, 0, 256);

		IHBeam = WorldInfo.MyEmitterPool.SpawnEmitter(IHBeamTemplate, traceLoc, r);
		IHBeam.SetAbsolute(false, false, false);
		IHBeam.SetVectorParameter('HitLocation', hitLocation);
		IHBeam.SetVectorParameter('SourceLocation', traceLoc);
		IHBeam.SetFloatParameter('Distance', VSize(hitLocation - traceLoc));
		IHBeam.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		IHBeam.bUpdateComponentInTick = true;
	}
}

simulated function EmitClouds()
{
	local vector l;
	local rotator r;
	local vector traceLoc, traceNorm;
	
	if (WorldInfo.NetMode != NM_DedicatedServer && IHBeamTemplate != None)
	{
		if (ArenaPawn(Instigator) != None)
			ArenaPawn(Instigator).GetAbilitySourceOffset(l, r);// + SourceOffset) >> );r
		
		r = Instigator.Controller.Rotation;
		l = l + (SourceOffset >> r);

		if (Trace(traceLoc, traceNorm, l + vect(0, 0, 256), l) == None)
			traceLoc = l + vect(0, 0, 256);

		Clouds = WorldInfo.MyEmitterPool.SpawnEmitter(CloudsTemplate, traceLoc, r);
		Clouds.SetAbsolute(false, true, false);
		Clouds.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		Clouds.bUpdateComponentInTick = true;
	}
}

defaultproperties
{
	WeaponFireTypes(0)=EWFT_InstantHit
	InstantHitDamageTypes(0)=class'Arena.Dmg_Shock'
	InstantHitMomentum(0)=+0.0

	
	IHBeamTemplate=ParticleSystem'ArenaAbilities.Particles.LightningBoltPS'
	CloudsTemplate=ParticleSystem'Tempest.Particles.CloudParticles'
	
	FireStartAnim=LightningBoltStart
	FireEndAnim=LightningBoltEnd
	
	FireSound=SoundCue'ArenaAbilities.Audio.LightningBoltSC'
	
	BaseDamage=650
	WeaponRange=2048
	CoolDown=5
	EnergyCost=300	
	AbilityName="Lightning Bolt"
	AbilityIcon="ArenaAbilities.Icons.LightningBolt"
	Extent=0.75
	
	CanHold=false
	IsPassive=false
	CanCharge=false
}