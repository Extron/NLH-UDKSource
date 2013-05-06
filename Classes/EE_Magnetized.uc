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

/**
 * The charge of the current effect.
 */
var int Charge;


simulated function UpdateEffect(float dt)
{
	local DynamicEnvironmentObject obj;
	local EE_Magnetized effect;
	local vector force;
	local vector displacement;
	local int direction;
	local int otherCharge;

	foreach Actor(Affectee).CollidingActors(class'Arena.DynamicEnvironmentObject', obj, Range, Actor(Affectee).Location)
	{
		if (obj == Affectee)
			continue;
			
		displacement = obj.Location - Actor(Affectee).Location;
		
		if (obj.HasProperties(Properties))
		{		
			if (obj.HasEffect(EffectName))
			{
				effect = EE_Magnetized(obj.ActiveEffect.FindEffect('EE_Magnetized'));
				
				if (effect != None)
					otherCharge = effect.Charge;
				else
					otherCharge = 1;
					
				direction = Charge * otherCharge;
			}
			else
				direction = -1;
				
			force = Magnitude * Direction * Normal(displacement) / (Range * Range / (FMax(Range - VSize(displacement), 0.1) ** 2));
			obj.StaticMeshComponent.AddForce(force);
			
			if (direction < 0 && DynamicEnvironmentObject(Affectee) != None)
				DynamicEnvironmentObject(Affectee).StaticMeshComponent.AddForce(-force);
		}
	}
}

defaultproperties
{
	Properties[0]="Magnetic"
	
	EffectName="Magnetized"
	Range=1000
	Magnitude=100
	Duration=30
	Charge=1
}