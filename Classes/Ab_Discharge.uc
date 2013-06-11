/*******************************************************************************
	Ab_Discharge

	Creation date: 07/06/2013 16:02
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Ab_Discharge extends Ab_LightningBolt;


/**
 * The range that the discharge can occur over.
 */
var float DischargeRange;


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
	
	if (attractor != None)
		Discharge(impact);
}

simulated function Discharge(ImpactInfo hitInfo)
{
	local Actor iter;
	local Actor attractor;
	local ImpactInfo impact;
	local bool oldCA, oldBA;
	
	attractor = None;

	hitInfo.HitActor.bProjTarget = false;
	oldCA = hitInfo.HitActor.bCollideActors;
	oldBA = hitInfo.HitActor.bBlockActors;
	hitInfo.HitActor.SetCollision(false, false);
	
	foreach VisibleCollidingActors(class'Actor', iter, DischargeRange, hitInfo.HitActor.Location)
	{
		if (IEnvObj(iter) != None && iter != hitInfo.HitActor)
		{
			if (IEnvObj(iter).HasProperty("Conductive") && (attractor == None || VSize(attractor.Location - hitInfo.HitActor.Location) > VSize(iter.Location - hitInfo.HitActor.Location)))
				attractor = iter;
		}
		else if (ArenaPawn(iter) != None && iter != hitInfo.HitActor) //Note that it is now possible that the discharge can hit the one that fired it.
		{
			if (ArenaPawn(iter).IsConductive() && (attractor == None || VSize(attractor.Location - hitInfo.HitActor.Location) > VSize(iter.Location - hitInfo.HitActor.Location)))
				attractor = iter;
		}
	}
	
	if (attractor != None)
	{
		impact = CalcWeaponFire(hitInfo.HitActor.Location, attractor.Location);

		InstantHitDamage[0] *= 0.5;
		
		EmitDischargeBeam(hitInfo.HitActor.Location, impact.HitLocation);
		ProcessInstantHit(CurrentFireMode, impact);
	}
	
	hitInfo.HitActor.bProjTarget = true;
	hitInfo.HitActor.SetCollision(oldCA, oldBA);
}

simulated function EmitDischargeBeam(vector start, vector end)
{
	if (WorldInfo.NetMode != NM_DedicatedServer && IHBeamTemplate != None)
	{
		IHBeam = WorldInfo.MyEmitterPool.SpawnEmitter(IHBeamTemplate, start);
		IHBeam.SetAbsolute(false, false, false);
		IHBeam.SetVectorParameter('HitLocation', end);
		IHBeam.SetVectorParameter('SourceLocation', start);
		IHBeam.SetFloatParameter('Distance', VSize(end - start));
		IHBeam.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		IHBeam.bUpdateComponentInTick = true;
	}
}

defaultproperties
{
	AbilityName="Discharge"
	DischargeRange=1024
}