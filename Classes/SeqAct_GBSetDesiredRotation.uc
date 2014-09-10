/*******************************************************************************
	SeqAct_GBSetDesiredRotatio

	Creation date: 08/09/2014 09:33
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class SeqAct_GBSetDesiredRotation extends SequenceAction;

/**
 * The desired rotation of the glass box.
 */
var vector DesiredRotation;

/**
 * The time the rotation should take.
 */
var float RotationTime;

defaultproperties
{
	ObjName="Set Glass Box Desired Rotation"
	HandlerName="SetDesiredRotation"
	RotationTime=15
	
	VariableLinks[1]=(ExpectedType=class'SeqVar_Float', LinkDesc="Rotation Time", bWriteable=true, PropertyName=RotationTime)
	VariableLinks[2]=(ExpectedType=class'SeqVar_Vector', LinkDesc="Rotation", bWriteable=true, PropertyName=DesiredRotation)
}