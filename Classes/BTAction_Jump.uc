/*******************************************************************************
	BTAction_Jump

	Creation date: 21/04/2014 16:49
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class BTAction_Jump extends BTAction;

/**
 * The position in the world to jump to.
 */
var vector Destination;

/**
 * The maximum velocity that the bot can have for jumping.
 */
var float MaxVelocity;

/**
 * The strength of gravity of the world.
 */
var float Gravity;

/**
 * The height to jump at.
 */
var float Height;

/**
 * The tolerance in distance from the destination to be within to consider the jump a success.
 */
var float SuccessTolerance;

/**
 * The stamina cost that is spent when the bot jumps.
 */
var float StaminaCost;


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
			if (binding[0] == "Destination")
				Destination = vector(binding[1]);
			else if (binding[0] == "Height")
				Height = float(binding[1]);
			else if (binding[0] == "MaxVelocity")
				MaxVelocity = float(binding[1]);
			else if (binding[0] == "Gravity")
				Gravity = float(binding[1]);
			else if (binding[0] == "SuccessTolerance")
				SuccessTolerance = float(binding[1]);
			else if (binding[0] == "StaminaCost")
				StaminaCost = float(binding[1]);
		}
	}
}

simulated function vector GetJumpVelocity()
{
	local vector d, v;
	local float transverseV, longitudeV;
	
	d = Destination - Controller.Pawn.Location;
	
	transverseV = Sqrt(2 * Gravity * Height);
	longitudeV = Sqrt(d.x * d.x + d.y * d.y) * transverseV / (2 * (2 * Height - d.z));
	
	v = d;
	v.z = 0;
	v = Normal(v);
	
	v.z = transverseV;
	v.x *= longitudeV;
	v.y *= longitudeV;
	
	return v;
}

state Running
{
	simulated function BeginState(name prev)
	{
		local vector v;
		
		OnRunning(self);

		if (ArenaPawn(Controller.Pawn).Stamina < StaminaCost)
			
		v = GetJumpVelocity();
		
		if (VSize(v) < MaxVelocity)
		{
			Controller.Pawn.AddVelocity(v, vect(0, 0, 0), None);
			Controller.Pawn.SetPhysics(PHYS_Falling);
		}
		else
		{
			GotoState('Failed');
		}
	}
	
	simulated function Update(float dt)
	{
		if (Abs(Controller.Pawn.Velocity.z) <= 0)
			EndJump();
	}
	
	simulated function EndJump()
	{
		Controller.Pawn.AddVelocity(-Controller.Pawn.Velocity, vect(0, 0, 0), None);
		
		if (VSize(Controller.Pawn.Location - Destination) <= SuccessTolerance)
			GotoState('Succeeded');
		else
			GotoState('Failed');
	}
}

defaultproperties
{
	SuccessTolerance=5
}