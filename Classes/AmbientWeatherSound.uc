/*******************************************************************************
	AmbientWeatherSound

	Creation date: 04/06/2014 20:09
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class AmbientWeatherSound extends Actor
	placeable;

/**
 * A struct that stores a sound cue with a weather intensity range within which the sound will be played.
 */
struct AmbientWeatherSoundCue
{
	/**
	 * The sound to play.
	 */
	var() SoundCue Sound;
	
	/**
	 * The time of day that the sound starts.  Enter a number between 0 and 23, corresponding to hours in a day.
	 */
	var() float MinimumIntensity;
	
	/**
	 * The time of day that the sound stops.  Enter a number between 0 and 23, corresponding to hours in a day.
	 */
	var() float MaximumIntensity;
	
	/**
	 * Indicates that the sound playes when it is raining.
	 */
	var() bool Rain;
	
	/**
	 * Indicates that the sound plays when it is snowing.
	 */
	var() bool Snow;
	
	/**
	 * Indicates that any AmbientToDSound actors on the level will be silenced while this sound is playing.
	 */
	var() bool OverrideAmbientToD;
};

/**
 * The list of sounds to play during a day/night cycle.
 */
var(Sound) array<AmbientWeatherSoundCue> Sounds;

/**
 * The level's weather manager.
 */
var WeatherManager WeatherManager;

/**
 * The first audio component.  Two components are used to handle a cross fade in the sound.
 */
var AudioComponent AudioComponent1;

/**
 * The second audio component.  Two components are used to handle a cross fade in the sound.
 */
var AudioComponent AudioComponent2;

/**
 * The index of the sound that is currently being played.
*/ 
var int CurrentSound;

/**
 * Indicates the current component that is playing the sound.
 */
var int CurrentComponent;


simulated function PostBeginPlay()
{
	local WeatherManager iter;
	
	super.PostBeginPlay();
	
	foreach AllActors(class'Arena.WeatherManager', iter)
	{
		if (iter != None)
		{
			WeatherManager = iter;
			break;
		}
	}
}

simulated function Tick(float dt)
{
	local AudioComponent currAC, nextAC;
	local int i;
	
	super.Tick(dt);
	
	if (CurrentComponent == 0)
	{
		currAC = AudioComponent1;
		nextAC = AudioComponent2;
	}
	else
	{
		currAC = AudioComponent2;
		nextAC = AudioComponent1;
	}
	
	if (Sounds[CurrentSound].MinimumIntensity > WeatherManager.WeatherIntensity || Sounds[CurrentSound].MaximumIntensity < WeatherManager.WeatherIntensity ||
		((Sounds[CurrentSound].Rain != WeatherManager.Raining) && (Sounds[CurrentSound].Snow != WeatherManager.Snowing)))
		currAC.FadeOut(0.5, 0.0);
	
	for (i = 0; i < Sounds.Length; i++)
	{
		if (WeatherManager.Raining && Sounds[i].Rain)
		{
			if (Sounds[i].MinimumIntensity < WeatherManager.WeatherIntensity && Sounds[i].MaximumIntensity > WeatherManager.WeatherIntensity && i != CurrentSound)
			{
				`log(self @ "Playing sound" @ CurrentSound @ Sounds[i].Sound);
				
				currAC.FadeOut(0.5, 0.0);
				nextAC.Stop();
				nextAC.SoundCue = Sounds[i].Sound;
				nextAC.FadeIn(0.5, 1.0);
				CurrentSound = i;
				CurrentComponent = 1 - CurrentComponent;
				
				if (Sounds[i].OverrideAmbientToD)
					MuteOtherAmbientSounds();
				else
					UnmuteOtherAmbientSounds();
			}
		}
		else if (WeatherManager.Snowing && Sounds[i].Snow)
		{
			if (Sounds[i].MinimumIntensity < WeatherManager.WeatherIntensity && Sounds[i].MaximumIntensity > WeatherManager.WeatherIntensity && i != CurrentSound)
			{
				currAC.FadeOut(0.5, 0.0);
				nextAC.Stop();
				nextAC.SoundCue = Sounds[i].Sound;
				nextAC.FadeIn(0.5, 1.0);
				CurrentSound = i;
				CurrentComponent = 1 - CurrentComponent;
				
				if (Sounds[i].OverrideAmbientToD)
					MuteOtherAmbientSounds();
				else
					UnmuteOtherAmbientSounds();
			}
		}
	}
}

simulated function MuteOtherAmbientSounds()
{
	local AmbientToDSound iter;
	
	foreach AllActors(class'Arena.AmbientToDSound', iter)
		iter.Mute(0.2);
}

simulated function UnmuteOtherAmbientSounds()
{
	local AmbientToDSound iter;
	
	foreach AllActors(class'Arena.AmbientToDSound', iter)
		iter.Unmute(0.2);
}

defaultproperties
{
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.AmbientSoundIcons.S_Ambient_Sound'
		Scale=0.25
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Sounds"
	End Object
	Components.Add(Sprite)
	
	Begin Object Class=DrawSoundRadiusComponent Name=DrawSoundRadius0
		SphereColor=(R=255,G=153,B=0)
	End Object
	Components.Add(DrawSoundRadius0)
	
	
	Begin Object Class=AudioComponent Name=AC1
		PreviewSoundRadius=DrawSoundRadius0
		bAutoPlay=false
		bStopWhenOwnerDestroyed=true
		bShouldRemainActiveIfDropped=true
	End Object
	AudioComponent1=AC1
	Components.Add(AC1)
	
	Begin Object Class=AudioComponent Name=AC2
		PreviewSoundRadius=DrawSoundRadius0
		bAutoPlay=false
		bStopWhenOwnerDestroyed=true
		bShouldRemainActiveIfDropped=true
	End Object
	AudioComponent2=AC2
	Components.Add(AC2)
}