/*******************************************************************************
	GFx_AbilityTooltip

	Creation date: 26/09/2013 08:21
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class GFx_AbilityTooltip extends GFxObject;

function SetAbilityDetails(class<ArenaAbility> ability)
{
	local array<GFxObject> effects;
	local class<DamageType> damageType;
	local class<StatusEffect> statusEffect;
	local GFxObject status;
	local int i;
	
	if (ability.default.InstantHitDamageTypes.Length > 0 && ability.default.InstantHitDamageTypes[0] != None)
		damageType = ability.default.InstantHitDamageTypes[0];
		
	if (class<ElementDamageType>(damageType) != None)
	{
		for (i = 0; i < class<ElementDamageType>(damageType).default.EntityEffects.Length; i++)
		{
			if (class<StatusEffect>(class<ElementDamageType>(DamageType).Default.EntityEffects[i]) != None)
			{
				statusEffect = class<StatusEffect>(class<ElementDamageType>(DamageType).Default.EntityEffects[i]);
				status = CreateObject("Object");
				
				status.SetString("effectName", statusEffect.default.EffectName);
				status.SetFloat("duration", statusEffect.default.Duration);
				effects.AddItem(status);
			}
		}
	}
	
	SetDisplay(ability.default.AbilityName, ability.default.AbilityDescription, ability.default.EnergyCost, ability.default.Cooldown, ability.default.BaseDamage, effects);
}

function SetDisplay(string abilityName, string description, float energyCost, float cooldown, float baseDamage, array<GFxObject> statusEffects)
{
	ActionScriptVoid("SetDisplay");
}