/*******************************************************************************
	SoundActor

	Creation date: 04/06/2014 20:32
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

/**
 * An actor that will play a sound and then destroy itself once complete.
 */
class SoundActor extends Actor;

var AudioComponent AudioComponent;

var bool AutoPlay;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	if (AutoPlay)
		AudioComponent.Play();
		
	AudioComponent.OnAudioFinished = AudioComplete;
}

simulated function AudioComplete(AudioComponent AC)
{
	AudioComponent.Stop();
	Destroy();
}

defaultproperties
{
	Begin Object class=AudioComponent Name=AC
		bAutoPlay=false
		bUseOwnerLocation=true
		bStopWhenOwnerDestroyed=true
	End Object
	
	Components.Add(AC)
	AudioComponent=AC
}