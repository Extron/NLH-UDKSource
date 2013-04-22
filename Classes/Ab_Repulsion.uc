/*******************************************************************************
	Ab_Repulsion

	Creation date: 18/01/2013 20:28
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Ab_Repulsion extends ArenaAbility;

/**
 * The template to use for burst hits for the ability.
 */
var ParticleSystem BurstTemplate;

/**
 * The instance of the burst particle system.
 */
var ParticleSystemComponent Burst;

/**
 * The radius of Repulse.
 */
var float Radius;

/**
 * The extent of Repulse, which determines the cone of space which Repulse effects.
 */
var float Extent;

/**
 * The strength of the impulse to apply to repulsed objects.
 */
var float Strength;


simulated function CustomFire()
{
	Repulse();
}

/**
 * Fires an EMP burst, affecting all players in the burst's radius.
 */
simulated function Repulse()
{
	local Actor iter;
	local vector origin;
	local vector impulse;
	local vector d;
	local rotator r;
	
	EmitBurst();
	
	if (ArenaPawn(Instigator) != None)
		ArenaPawn(Instigator).GetAbilitySourceOffset(origin, r);
	else 
		origin = Location;
		
	r = Instigator.Controller.Rotation;
	origin = origin + (SourceOffset >> r);
	
	`log("direction" @ (vect(1, 0, 0) >> r));
	
	if (ArenaPawn(Instigator) != None)
	{
		foreach CollidingActors(class'Actor', iter, Radius, origin)
		{			
			d = iter.Location - origin;
			impulse = Normal(d) * Strength / (Radius / FMax((Radius - VSize(d)), 0.1));
			
			if (Normal(d) Dot (vect(1, 0, 0) >> r) >= Extent)
			{
				if (ArenaPawn(iter) != None)
				{
					`log("Hit pawn" @ iter);
					
					ArenaPawn(iter).Mesh.AddImpulse(impulse, iter.Location);
				}
				else if (DynamicEnvironmentObject(iter) != None && DynamicEnvironmentObject(iter).HasProperty("Magnetic"))
				{
					`log("Hit block");
					`log("Dot" @ Normal(d) Dot (vect(1, 0, 0) >> r));
				
					if (!DynamicEnvironmentObject(iter).HasEffect("Magnetized"))
						DynamicEnvironmentObject(iter).AddEffect(Spawn(class'Arena.EE_Magnetized', iter), ArenaPlayerController(Instigator.Controller));
						
					DynamicEnvironmentObject(iter).StaticMeshComponent.AddImpulse(impulse, iter.Location);
				}
			}
		}
	}
}

simulated function EmitBurst()
{
	local vector l;
	local rotator r;
	
	if (WorldInfo.NetMode != NM_DedicatedServer && BurstTemplate != None)
	{
		if (ArenaPawn(Instigator) != None)
			ArenaPawn(Instigator).GetAbilitySourceOffset(l, r);
		
		r = Instigator.Controller.Rotation;
		l = l + (SourceOffset >> r);
		
		Burst = WorldInfo.MyEmitterPool.SpawnEmitter(BurstTemplate, l);
		Burst.SetAbsolute(false, false, false);
		Burst.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		Burst.bUpdateComponentInTick = true;
	}
}

defaultproperties
{
	WeaponFireTypes(0)=EWFT_Custom
	
	AbilityName="Repulse"
	CoolDown=5
	EnergyCost=350
	Radius=1000
	Extent=0.93
	Strength=2500
	
	BurstTemplate=ParticleSystem'ArenaParticles.Particles.EMPBubble'
	
	CanHold=false
	IsPassive=false
	CanCharge=false
}