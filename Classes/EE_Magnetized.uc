/*******************************************************************************
	EE_Magnetized

	Creation date: 14/09/2012 00:09
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class EE_Magnetized extends EnvironmentEffect;

/** The range that the magnetized effect can affect other objects. */
var float Range;

/** The magnitude of the force dealt by this effect. */
var float Magnitude;

simulated function UpdateEffect(float dt)
{
	local KActor obj;
	local vector force;
	local vector displacement;
	local int direction;
	
	foreach Actor(Affectee).DynamicActors(class'KActor', obj, class'IEnvObj')
	{
		displacement = obj.Location - Actor(Affectee).Location;
			
		if (VSize(displacement) <= Range && IEnvObj(obj).HasProperties(Properties))
		{
			if (IEnvObj(obj).HasEffect(EffectName))
				direction = 1;
			else
				direction = -1;
				
			force = Magnitude * Direction * Normal(displacement) / (displacement dot displacement);
			obj.StaticMeshComponent.AddForce(force);
		}
	}
}

defaultproperties
{
	Properties[0]="Conductive"
	Properties[1]="Magnetic"
	
	EffectName="Magnetized"
	Range=500
	Magnitude=1000
	Duration=30
}