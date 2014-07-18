/*******************************************************************************
	SA_LightningStrike

	Creation date: 04/06/2014 20:37
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class SA_LightningStrike extends SoundActor;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	`log(self @ "spawned");
}

defaultproperties
{
	Begin Object Name=AC
		SoundCue=SoundCue'ArenaWeather.Audio.LightningStrikeSC'
	End Object
	
	AutoPlay=true
}