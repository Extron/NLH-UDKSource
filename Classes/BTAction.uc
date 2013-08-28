/*******************************************************************************
	BTAction

	Creation date: 21/08/2013 23:08
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class BTAction extends BehaviorTreeNode;

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
			switch (binding[0])
			{
				case "NodeBias":
					if (BTSelector_Random(Parent) != None)
						BTSelector_Random(Parent).SetChildWeight(self, int(binding[1]));
						
					break;
			}
		}
	}
}