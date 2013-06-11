/*******************************************************************************
	Ab_LightningStorm

	Creation date: 07/06/2013 20:02
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Ab_LightningStorm extends Ab_Discharge;


/**
 * The range of the first and second discharges.
 */
var float FirstDischargeRange, SecondDischargeRange;

/**
 * The amount of bolts in the initial burst of lightning.
 */
var int InitialBurstCount;

/**
 * The amount of bolts in the first discharge.
 */
var int FirstDischargeBurstCount;

/**
 * The amount of bolts in the second discharge.
 */
var int SecondDischargeBurstCount;


simulated function InstantFire()
{
	local array<Actor> allHitActors;
	local array<Actor> attractors;
	local Actor iter;
	local Actor attractor;
	local ImpactInfo impact;
	local vector start, end;
	local int i;
	
	start = Instigator.GetWeaponStartTraceLocation();
	end = (start + vector(GetAdjustedAim(start)) * GetTraceRange());
	
	attractor = None;
	
	for (i = 0; i < InitialBurstCount; i++)
	{
		foreach VisibleCollidingActors(class'Actor', iter, GetTraceRange(), start)
		{
			if (Normal(iter.Location - start) dot Normal(end - start) >= Extent)
			{
				if (IEnvObj(iter) != None)
				{
					if (IEnvObj(iter).HasProperty("Conductive") && (attractor == None || VSize(attractor.Location - start) > VSize(iter.Location - start)) && attractors.Find(iter) == -1 &&
						allHitActors.Find(iter) == -1)
						attractor = iter;
				}
				else if (ArenaPawn(iter) != None && ArenaPawn(iter) != Instigator)
				{
					if (ArenaPawn(iter).IsConductive() && (attractor == None || VSize(attractor.Location - start) > VSize(iter.Location - start)) && attractors.Find(iter) == -1 &&
						allHitActors.Find(iter) == -1)
						attractor = iter;
				}
			}
		}

		if (attractor != None)
		{
			impact = CalcWeaponFire(start, attractor.Location);

			attractors.AddItem(attractor);
			allHitActors.AddItem(attractor);
		}
		else
		{
			if (attractors.Length == i && attractors.Length > 0)
				impact = CalcWeaponFire(start, attractors[i - 1].Location);
			else
				impact = CalcWeaponFire(start, end);
		}
		
		if (Role == ROLE_Authority)
		{
			SetFlashLocation(impact.HitLocation);	
		}

		EmitIHBeam(impact.HitLocation);
		
		if (ArenaPawn(Instigator) != None)
			InstantHitDamage[0] = ArenaPawn(Instigator).Stats.GetDamageGiven(BaseDamage, InstantHitDamageTypes[0]);

		ProcessInstantHit(CurrentFireMode, impact);
		
		if (attractor != None)
			FirstDischarge(impact, allHitActors);
	}
}

simulated function FirstDischarge(ImpactInfo hitInfo, out array<Actor> allHitActors)
{
	local array<Actor> attractors;
	local Actor iter;
	local Actor attractor;
	local ImpactInfo impact;
	local bool oldCA, oldBA;
	local int i;
	
	attractor = None;
	
	hitInfo.HitActor.bProjTarget = false;
	oldCA = hitInfo.HitActor.bCollideActors;
	oldBA = hitInfo.HitActor.bBlockActors;
	hitInfo.HitActor.SetCollision(false, false);
	
	for (i = 0; i < FirstDischargeBurstCount; i++)
	{
		foreach VisibleCollidingActors(class'Actor', iter, FirstDischargeRange, hitInfo.HitActor.Location)
		{
			if (IEnvObj(iter) != None && iter != hitInfo.HitActor)
			{
				if (IEnvObj(iter).HasProperty("Conductive") && (attractor == None || VSize(attractor.Location - hitInfo.HitActor.Location) > VSize(iter.Location - hitInfo.HitActor.Location)) && 
					attractors.Find(iter) == -1 && allHitActors.Find(iter) == -1)
					attractor = iter;
			}
			else if (ArenaPawn(iter) != None && ArenaPawn(iter) != hitInfo.HitActor) //Note that it is now possible that the discharge can hit the one that fired it.
			{
				if (ArenaPawn(iter).IsConductive() && (attractor == None || VSize(attractor.Location - hitInfo.HitActor.Location) > VSize(iter.Location - hitInfo.HitActor.Location)) && 
					attractors.Find(iter) == -1 && allHitActors.Find(iter) == -1)
					attractor = iter;
			}
		}
		
		if (attractor != None)
		{
			impact = CalcWeaponFire(hitInfo.HitActor.Location, attractor.Location);

			attractors.AddItem(attractor);
			allHitActors.AddItem(attractor);
			
			InstantHitDamage[0] = ArenaPawn(Instigator).Stats.GetDamageGiven(BaseDamage, InstantHitDamageTypes[0]) * 0.5;
			
			EmitDischargeBeam(hitInfo.HitActor.Location, impact.HitLocation);
			ProcessInstantHit(CurrentFireMode, impact);
			
			SecondDischarge(impact, allHitActors);
		}
		else if (attractors.Length == i && attractors.Length > 0)
		{
			impact = CalcWeaponFire(hitInfo.HitActor.Location, attractors[i - 1].Location);

			InstantHitDamage[0] = ArenaPawn(Instigator).Stats.GetDamageGiven(BaseDamage, InstantHitDamageTypes[0]) * 0.5;
			
			EmitDischargeBeam(hitInfo.HitActor.Location, impact.HitLocation);
			ProcessInstantHit(CurrentFireMode, impact);
						
			SecondDischarge(impact, allHitActors);
		}
	}
	
	hitInfo.HitActor.bProjTarget = true;
	hitInfo.HitActor.SetCollision(oldCA, oldBA);
}

simulated function SecondDischarge(ImpactInfo hitInfo, out array<Actor> allHitActors)
{
	local array<Actor> attractors;
	local Actor iter;
	local Actor attractor;
	local ImpactInfo impact;
	local bool oldCA, oldBA;
	local int i;
	
	attractor = None;
	
	hitInfo.HitActor.bProjTarget = false;
	oldCA = hitInfo.HitActor.bCollideActors;
	oldBA = hitInfo.HitActor.bBlockActors;
	hitInfo.HitActor.SetCollision(false, false);

	for (i = 0; i < SecondDischargeBurstCount; i++)
	{
		foreach VisibleCollidingActors(class'Actor', iter, SecondDischargeRange, hitInfo.HitActor.Location)
		{
			if (IEnvObj(iter) != None && iter != hitInfo.HitActor)
			{
				if (IEnvObj(iter).HasProperty("Conductive") && (attractor == None || VSize(attractor.Location - hitInfo.HitActor.Location) > VSize(iter.Location - hitInfo.HitActor.Location)) && 
					attractors.Find(iter) == -1 && allHitActors.Find(iter) == -1)
					attractor = iter;
			}
			else if (ArenaPawn(iter) != None && ArenaPawn(iter) != hitInfo.HitActor) //Note that it is now possible that the discharge can hit the one that fired it.
			{
				if (ArenaPawn(iter).IsConductive() && (attractor == None || VSize(attractor.Location - hitInfo.HitActor.Location) > VSize(iter.Location - hitInfo.HitActor.Location)) && 
					attractors.Find(iter) == -1 && allHitActors.Find(iter) == -1)
					attractor = iter;
			}
		}
		
		if (attractor != None)
		{
			impact = CalcWeaponFire(hitInfo.HitActor.Location, attractor.Location);

			attractors.AddItem(attractor);
			allHitActors.AddItem(attractor);
			
			InstantHitDamage[0] = ArenaPawn(Instigator).Stats.GetDamageGiven(BaseDamage, InstantHitDamageTypes[0]) * 0.25;
			
			EmitDischargeBeam(hitInfo.HitActor.Location, impact.HitLocation);
			ProcessInstantHit(CurrentFireMode, impact);
		}
		else if (attractors.Length == i && attractors.Length > 0)
		{
			impact = CalcWeaponFire(hitInfo.HitActor.Location, attractors[i - 1].Location);

			InstantHitDamage[0] = ArenaPawn(Instigator).Stats.GetDamageGiven(BaseDamage, InstantHitDamageTypes[0]) * 0.25;
			
			EmitDischargeBeam(hitInfo.HitActor.Location, impact.HitLocation);
			ProcessInstantHit(CurrentFireMode, impact);
		}
	}
	
	hitInfo.HitActor.bProjTarget = true;
	hitInfo.HitActor.SetCollision(oldCA, oldBA);
}


defaultproperties
{
	AbilityName="Lightning Storm"
	FirstDischargeRange=1024
	SecondDischargeRange=512
	InitialBurstCount=3
	FirstDischargeBurstCount=2
	SecondDischargeBurstCount=1
}