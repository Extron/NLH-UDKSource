/*******************************************************************************
	Ab_EMP

	Creation date: 05/10/2012 15:11
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Ab_EMP extends ArenaAbility;

/**
 * The template to use for instant hits for the ability.
 */
var ParticleSystem EMPBurstTemplate;

/**
 * The instance of the IH Beam particle system.
 */
var ParticleSystemComponent EMPBurst;

/**
 * The radius of the EMP burst.
 */
var float Radius;


simulated function CustomFire()
{
	EMPBlast();
}

/**
 * Fires an EMP burst, affecting all players in the burst's radius.
 */
simulated function EMPBlast()
{
	local ArenaPawn iter;

	EmitEMPBurst();
	
	if (ArenaPawn(Instigator) != None)
	{
		foreach Instigator.WorldInfo.AllPawns(class'ArenaPawn', iter, Instigator.Location, Radius)
		{
			iter.RebootElectronics(ArenaPawn(Instigator));
		}
	}
}

simulated function EmitEMPBurst()
{
	local vector l;
	local rotator r;
	
	if (WorldInfo.NetMode != NM_DedicatedServer && EMPBurstTemplate != None)
	{
		if (ArenaPawn(Instigator) != None)
			ArenaPawn(Instigator).GetAbilitySourceOffset(l, r);
		
		r = Instigator.Controller.Rotation;
		l = l + (SourceOffset >> r);
		
		EMPBurst = WorldInfo.MyEmitterPool.SpawnEmitter(EMPBurstTemplate, l);
		EMPBurst.SetAbsolute(false, false, false);
		EMPBurst.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
		EMPBurst.bUpdateComponentInTick = true;
	}
}

defaultproperties
{
	WeaponFireTypes(0)=EWFT_Custom
	
	FireSound=SoundCue'ArenaAbilities.Audio.EMPBurstSC'
	
	AbilityName="EMP"
	CoolDown=5
	EnergyCost=350
	Radius=1000
	
	EMPBurstTemplate=ParticleSystem'ArenaParticles.Particles.EMPBubble'
	
	CanHold=false
	IsPassive=false
	CanCharge=false
}