/*******************************************************************************
	GlobalGameConstants

	Creation date: 11/08/2012 15:29
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GlobalGameConstants extends Object;

/* Maps each stat name to an index value. */
var Array<string> StatMap;

/* A list of tuples containing (stat default values, stat max values). */
var Array<vector2d> StatValues;

/* Maps each player factor name to an index value. */
var Array<string> FactorMap;

/* A list of vectors containing (factor min, factor max, factor constant). */
var Array<vector> FactorValues;


/*
 * Initializes the global game constants. 
 */
simulated function Initialize()
{
	SetFactorConstant("Look Factor", (1 - GetFactorMin("Look Factor")) / (GetStatNormalizedDefault("Mobility") * GetFactorRange("Look Factor")));
	SetFactorConstant("Movement Speed", (1 - GetFactorMin("Movement Speed")) / ((GetStatNormalizedDefault("Mobility") * GetStatNormalizedDefault("Movement") / GetStatNormalizedDefault("Weight")) * GetFactorRange("Movement Speed")));									  
	SetFactorConstant("ADS Speed", (0.25 - GetFactorMin("ADS Speed")) / ((GetStatNormalizedDefault("Weapon Weight") / GetStatNormalizedDefault("Mobility")) * GetFactorRange("ADS Speed")));
	SetFactorConstant("Jump Z", (1 - GetFactorMin("Jump Z")) / ((GetStatNormalizedDefault("Mobility") * GetStatNormalizedDefault("Jump") / GetStatNormalizedDefault("Weight")) * GetFactorRange("Jump Z")));
	SetFactorConstant("Sprint Speed", (2.5 - GetFactorMin("Sprint Speed")) / ((GetStatNormalizedDefault("Mobility") * GetStatNormalizedDefault("Movement") / GetStatNormalizedDefault("Weight")) * GetFactorRange("Sprint Speed")));
	SetFactorConstant("Accuracy Factor", (1 - GetFactorMin("Accuracy Factor")) / ((1 / GetStatNormalizedDefault("Accuracy")) * GetFactorRange("Accuracy Factor")));
}

function float NormalizedStat(string statName, float statValue)
{
	local int i;
	
	i = StatMap.Find(statName);
	
	if (i == -1)
	{
		`log("Couli not find constant for stat" @ statName);
		return 0;
	}
	
	return statValue / StatValues[i].Y;
}

function float GetStatDefault(string statName)
{
	local int i;
	
	i = StatMap.Find(statName);
	
	if (i == -1)
		return 0;
		
	return StatValues[i].X;
}

function float GetStatMax(string statName)
{
	local int i;
	
	i = StatMap.Find(statName);
	
	if (i == -1)
		return 0;
		
	return StatValues[i].Y;
}

function float GetStatNormalizedDefault(string statName)
{
	local int i;
	
	i = StatMap.Find(statName);
	
	if (i == -1)
		return 0;
		
	return StatValues[i].X / StatValues[i].Y;
}

function float GetFactorMin(string factorName)
{
	local int i;
	
	i = FactorMap.Find(factorName);
	
	if (i == -1)
		return 0;
		
	return FactorValues[i].X;
}

function float GetFactorMax(string factorName)
{
	local int i;
	
	i = FactorMap.Find(factorName);
	
	if (i == -1)
		return 0;
		
	return FactorValues[i].Y;
}

function float GetFactorConstant(string factorName)
{
	local int i;
	
	i = FactorMap.Find(factorName);
	
	if (i == -1)
		return 0;
		
	return FactorValues[i].Z;
}

function float GetFactorRange(string factorName)
{
	local int i;
	
	i = FactorMap.Find(factorName);
	
	if (i == -1)
		return 0;
		
	return FactorValues[i].Y - FactorValues[i].X;
}

function SetFactorMin(string factorName, float factorMin)
{
	local int i;
	local vector v;
	
	i = FactorMap.Find(factorName);
	
	if (i == -1)
	{
		FactorMap.AddItem(factorName);
		FactorValues.AddItem(v);
		i = FactorMap.Length - 1;
	}

	FactorValues[i].X = factorMin;
}

function SetFactorMax(string factorName, float factorMax)
{
	local int i;
	local vector v;
	
	i = FactorMap.Find(factorName);
	
	if (i == -1)
	{
		FactorMap.AddItem(factorName);
		FactorValues.AddItem(v);
		i = FactorMap.Length - 1;
	}

	FactorValues[i].Y = factorMax;
}

function SetFactorConstant(string factorName, float factorConstant)
{
	local int i;
	local vector v;
	
	i = FactorMap.Find(factorName);
	
	if (i == -1)
	{
		FactorMap.AddItem(factorName);
		FactorValues.AddItem(v);
		i = FactorMap.Length - 1;
	}

	FactorValues[i].Z = factorConstant;
}

defaultproperties
{
	StatMap[0]="Mobility"
	StatMap[1]="Stability"
	StatMap[2]="Accuracy"
	StatMap[3]="Movement"
	StatMap[4]="Jump"
	StatMap[5]="Weight"
	StatMap[6]="Weapon Weight"
	StatMap[7]="Health"
	StatMap[8]="Energy"
	StatMap[9]="Stamina"
	StatMap[10]="Weapon Accuracy"
	StatMap[11]="Weapon Stability"
	StatMap[12]="Weapon Mobility"
	StatMap[13]="Weapon Recoil"
	StatMap[14]="Weapon Zoom"
	StatMap[15]="Weapon Rate of Fire"
	StatMap[16]="Weapon Rate of Cycle"
	StatMap[17]="Weapon Damage Output"
	StatMap[18]="Weapon Cool Down Rate"
	StatMap[19]="Weapon Overheat Delay"
	StatMap[20]="Weapon Heat Cost"
	StatMap[21]="Bloom"
	StatMap[22]="ADS Accuracy"
	
	StatValues[0]=(X=0.5,Y=1)
	StatValues[1]=(X=0.5,Y=1)
	StatValues[2]=(X=0.5,Y=1)
	StatValues[3]=(X=0.5,Y=1)
	StatValues[4]=(X=0.5,Y=1)
	StatValues[5]=(X=75,Y=200)
	StatValues[6]=(X=7.5,Y=25)
	StatValues[7]=(X=1000,Y=1000)
	StatValues[8]=(X=1000,Y=1000)
	StatValues[9]=(X=1000,Y=1000)
	StatValues[10]=(X=0.5,Y=1)
	StatValues[11]=(X=0.5,Y=1)
	StatValues[12]=(X=0.5,Y=1)
	StatValues[13]=(X=0.5,Y=1)
	StatValues[14]=(X=1,Y=5)
	StatValues[15]=(X=0.5,Y=1)
	StatValues[16]=(X=1,Y=5)
	StatValues[17]=(X=1,Y=5)
	StatValues[18]=(X=0,Y=5)
	StatValues[19]=(X=0,Y=5)
	StatValues[20]=(X=0,Y=5)
	StatValues[21]=(X=0,Y=100)
	StatValues[22]=(X=0.1,Y=1)
	
	FactorMap[0]="ADS Speed"
	FactorMap[1]="Look Factor"
	FactorMap[2]="Movement Speed"
	FactorMap[3]="Jump Z"
	FactorMap[4]="Sprint Speed"
	FactorMap[5]="Accuracy Shift"
	FactorMap[6]="Accuracy Factor"
	FactorMap[7]="Bloom Cost"
	FactorMap[8]="Bloom Factor"
	
	FactorValues[0]=(X=0.1,Y=0.5,Z=1)
	FactorValues[1]=(X=0.5,Y=1.125,Z=1)
	FactorValues[2]=(X=0.5,Y=1.75,Z=1)
	FactorValues[3]=(X=0.75,Y=1.75,Z=1)
	FactorValues[4]=(X=1.5,Y=3.75,Z=1)
	FactorValues[5]=(X=0,Y=0.1,Z=1)
	FactorValues[6]=(X=0.01,Y=1,Z=1)
	FactorValues[7]=(X=0,Y=5,Z=1)
	FactorValues[8]=(X=0.01,Y=5,Z=1)
}