/*******************************************************************************
	GFx_DamageRing

	Creation date: 15/06/2013 17:55
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_DamageRing extends GFxObject;

function IndicateHit(vector direction)
{
	local vector v;
	local float a;
	
	v = Normal(direction * vect(1, 1, 0));
	a = Acos(vect(0, 1, 0) dot v);

	if (vect(1, 0, 0) dot v > 0)
		a = -a;
		
	AddDamageIndicator(a);
}

function RotateRing(rotator playerRotation)
{
	local vector v;
	local float a;
	
	v = Normal((vect(0, 1, 0) >> playerRotation) * vect(1, 1, 0));
	a = -Acos(vect(0, 1, 0) dot v);

	if (vect(1, 0, 0) dot v > 0)
		a = -a;
		
	a += Pi / 2;
	
	SetFloat("rotation", 180 * a / PI);
}

function AddDamageIndicator(float angle)
{
	ActionScriptVoid("AddDamageIndicator");
}