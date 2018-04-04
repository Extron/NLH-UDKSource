/*******************************************************************************
	Wp_PhotonEmitter

	Creation date: 20/09/2014 13:59
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

/**
 * A base class for all photon-based weapons.
 */
class Wp_PhotonEmitter extends ArenaWeaponBase;

/**
 * The maximum allowed impacts that we should compute for the laser beam within the world, such as reflections and refractions.
 */
var int MaxImpacts;

simulated function ImpactInfo CalcWeaponFire(vector start, vector end, optional out array<ImpactInfo> impacts, optional vector extent)
{
	local Actor hitActor;
	local ArenaPMP physMatProperties;
	local vector hitLoc, hitNorm;
	local TraceHitInfo traceHit;
	local ImpactInfo impact;
	local float n;
	
	hitActor = GetTraceOwner().Trace(hitLoc, hitNorm, end, start, true, extent, traceHit, TRACEFLAG_Bullet);
	
	if (hitActor == None)
		hitLoc = end;
		
	impact.HitActor = hitActor;
	impact.HitLocation = hitLoc;
	impact.HitNormal	= hitNorm;
	impact.RayDir = Normal(end - start);
	impact.StartTrace = start;
	impact.HitInfo = traceHit;

	impacts.AddItem(impact);
	
	if (traceHit.PhysMaterial != None)
		physMatProperties = ArenaPMP(traceHit.PhysMaterial.PhysicalMaterialProperty);
	
	if (HitActor != None && physMatProperties != None && impacts.Length < MaxImpacts)
	{
		if (physMatProperties.HasProperty("Reflective"))
		{
			start = hitLoc;
			end = (impact.RayDir - 2 * (impact.RayDir dot hitNorm) * hitNorm) * GetTraceRange();
			
			CalcWeaponFire(start, end, impacts, extent);
		}
		
		if (physMatProperties.HasProperty("Transparent"))
		{
			start = hitLoc;
			
			n = 1.5;
			
			if (impact.RayDir dot hitNorm > 0)
				n = 1 / n;
				
			end = (n * impact.RayDir - (n * (impact.RayDir dot hitNorm) + Sqrt(1 - n * n * (1 - (impact.RayDir dot hitNorm) ** 2))) * hitNorm) * GetTraceRange();
			
			CalcWeaponFire(start, end, impacts, extent);
		}
	}
	
	return impact;
}

defaultproperties
{
	WeaponFireTypes[0]=EWFT_InstantHit
	InstantHitDamageTypes[0]=class'Arena.Dmg_LightBeam'
	InstantHitMomentum[0]=500
	Type=WTHardLightRifle
	MaxImpacts=3
}