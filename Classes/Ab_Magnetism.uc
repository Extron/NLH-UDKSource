/*******************************************************************************
	Ab_Magnetism

	Creation date: 21/04/2013 19:37
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Ab_Magnetism extends Ab_Repulsion;

/**
 * The active charge of the ability.  
 */
var int CurrentCharge;



simulated function CustomFire()
{
	Magnetize();
	
	CurrentCharge *= -1;
}

/**
 * Fires an EMP burst, affecting all players in the burst's radius.
 */
simulated function Magnetize()
{
	local Actor iter;
	local EnvironmentEffect effect;
	local vector origin;
	local vector d;
	local vector hitLoc, hitNorm;
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
		foreach TraceActors(class'Actor', iter, hitLoc, hitNorm, origin + (vect(1, 0, 0) >> r) * Radius, origin)
		{
				if (IEnvObj(iter) != None && IEnvObj(iter).HasProperty("Magnetic"))
				{
					`log("Hit actor" @ iter);
					`log("Dot" @ Normal(d) Dot (vect(1, 0, 0) >> r));
				
					if (!IEnvObj(iter).HasEffect("Magnetized"))
					{
						effect = Spawn(class'Arena.EE_Magnetized', iter);
						EE_Magnetized(effect).Charge = CurrentCharge;
						
						IEnvObj(iter).AddEffect(Spawn(class'Arena.EE_Magnetized', iter));
					}
					else
					{
						`log("Object has magnetized already.");
						
						effect = IEnvObj(iter).FindEffect('EE_Magnetized');
						
						`log("Results of search:" @ effect @ EE_Magnetized(effect).Charge);
						
						if (EE_Magnetized(effect) != None)
							EE_Magnetized(effect).Charge = CurrentCharge;
					}
				}
		}
	}
}

defaultproperties
{
	FireSound=SoundCue'ArenaAbilities.Audio.MagnetizeSC'

	AbilityName="Magnetism"
	CurrentCharge=1
}
