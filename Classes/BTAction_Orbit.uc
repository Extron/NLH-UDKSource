/*******************************************************************************
	BTAction_Orbit

	Creation date: 23/08/2013 00:27
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class BTAction_Orbit extends BTAction;

var float AzimuthDirection;
var float ZenithDirection;
var float RadialDirection;

var float AzimuthSpeed;
var float ZenithSpeed;
var float RadialSpeed;

var float RadialMax;
var float RadialMin;
var float ZenithMax;
var float ZenithMin;

var float OrbitTime;

/**
 * Parses a list of parameter assignment strings and sets the corresponding parameters.  Should be overridden in child classes.
 */
simulated function SetParameters(array<string> parameters)
{
	local array<string> binding;
	local int i;
		
	super.SetParameters(parameters);
	
	for (i = 0; i < parameters.Length; i++)
	{
		binding = SplitString(parameters[i], "=");
		
		if (binding.Length == 2)
		{
			if (binding[0] == "AzimuthDirection")
				AzimuthDirection = float(binding[1]);
			else if (binding[0] == "ZenithDirection")
				ZenithDirection = float(binding[1]);
			else if (binding[0] == "RadialDirection")
				RadialDirection = float(binding[1]);
			else if (binding[0] == "AzimuthSpeed")
				AzimuthSpeed = float(binding[1]);
			else if (binding[0] == "ZenithSpeed")
				ZenithSpeed = float(binding[1]);
			else if (binding[0] == "RadialSpeed")
				RadialSpeed = float(binding[1]);
			else if (binding[0] == "RadialMax")
				RadialMax = float(binding[1]);
			else if (binding[0] == "RadialMin")
				RadialMin = float(binding[1]);
			else if (binding[0] == "ZenithMax")
				ZenithMax = float(binding[1]);
			else if (binding[0] == "ZenithMin")
				ZenithMin = float(binding[1]);
			else if (binding[0] == "OrbitTime")
				OrbitTime = float(binding[1]);
		}
	}
}

state Running
{
	simulated function Update(float dt)
	{
		local vector r, v_az, v_zen, v_rad;
		local float zenith, radius;
		local float speed_az, speed_zen, speed_rad;
		local float time;
		
		if (Controller.Focus == None)
		{
			GotoState('Failed');
			return;
		}
		
		time = GetTimerCount('EndOrbit');
		
		Controller.Pawn.AddVelocity(-Controller.Pawn.Velocity, vect(0, 0, 0), None);

		r = Normal(Controller.Focus.Location - Controller.Pawn.Location);
		radius = VSize(Controller.Focus.Location - Controller.Pawn.Location);
		
		v_az = (r cross vect(0, 0, 1)) * AzimuthDirection;
		
		zenith = ACos(Controller.Pawn.Location.z / radius);
		
		if (zenith > ZenithMin && zenith < ZenithMax) 
			v_zen = (r cross Normal(v_az)) * ZenithDirection;
		
		if (radius < RadialMax && radius > RadialMin)
			v_rad = Normal(r) * RadialDirection;
			
		speed_az = -((4 * AzimuthSpeed) / (OrbitTime ** 2)) * (time - OrbitTime * 0.5) ** 2 + AzimuthSpeed;
		speed_zen = -((4 * ZenithSpeed) / (OrbitTime ** 2)) * (time - OrbitTime * 0.5) ** 2 + ZenithSpeed;
		speed_rad = -((4 * RadialSpeed) / (OrbitTime ** 2)) * (time - OrbitTime * 0.5) ** 2 + RadialSpeed;
		
		Controller.Pawn.AddVelocity(v_az * speed_az + v_zen * speed_zen * 0.5 + v_rad * speed_rad * 0.5, vect(0, 0, 0), None);
	}
	
	simulated function EndOrbit()
	{
		Controller.Pawn.AddVelocity(-Controller.Pawn.Velocity, vect(0, 0, 0), None);
		GotoState('Succeeded');
	}
	
Begin:
	SetTimer(OrbitTime, false, 'EndOrbit');
}
