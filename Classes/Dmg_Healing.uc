/*******************************************************************************
	Dmg_Healing

	Creation date: 29/08/2014 09:22
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class Dmg_Healing extends ElementDamageType;

defaultproperties
{
	ActionString="Healed"
	DisplayColor=0xFFFFFF
	
	EntityEffects[1]=class'Arena.SE_Heal'
}