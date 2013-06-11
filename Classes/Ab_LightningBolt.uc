/*******************************************************************************
	Ab_LightningBolt

	Creation date: 15/05/2013 14:21
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Ab_LightningBolt extends ArenaAbility;

/**
 * This measures the extent to which Lightning Bolt can auto target.  If it is 1, then it can only target objects 
 * directly in front of the player.  If it is 0, then it can target anything that is in front of the player, no matter
 * how far to the left or right they are wrt where the player is looking.
 */
var float Extent;


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
	
	`log("Attractor" @ attractor);
	
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
	
	if (WorldInfo.NetMode != NM_DedicatedServer && IHBeamTemplate != None)
	{
		if (ArenaPawn(Instigator) != None)
			ArenaPawn(Instigator).GetAbilitySourceOffset(l, r);// + SourceOffset) >> );r
		
		r = Instigator.Controller.Rotation;
		l = l + (SourceOffset >> r);

		IHBeam = WorldInfo.MyEmitterPool.SpawnEmitter(IHBeamTemplate, l, r);
		IHBeam.SetAbsolute(false, false, false);
		IHBeam.SetVectorParameter('HitLocation', hitLocation);
		IHBeam.SetVectorParameter('SourceLocation', l);
		IHBeam.SetFloatParameter('Distance', VSize(hitLocation - l));
		IHBeam.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		IHBeam.bUpdateComponentInTick = true;
	}
}

defaultproperties
{
	WeaponFireTypes(0)=EWFT_InstantHit
	InstantHitDamageTypes(0)=class'Arena.Dmg_Shock'
	InstantHitMomentum(0)=+0.0

	
	IHBeamTemplate=ParticleSystem'ArenaAbilities.Particles.LightningBoltPS'
	
	BaseDamage=650
	WeaponRange=2048
	CoolDown=5
	EnergyCost=300	
	AbilityName="Lightning Bolt"
	Extent=0.75
	
	CanHold=false
	IsPassive=false
	CanCharge=false
}