/*******************************************************************************
	AmbientToDSound

	Creation date: 28/05/2014 20:11
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

/**
 * This is a sound generating actor that changes the sound being played based on the time of day in the level.
 */
class AmbientToDSound extends Actor
	placeable;

/**
 * A struct that stores a sound cue with a start and stop time within which the sound will be played.
 */
struct AmbientSoundCue
{
	/**
	 * The sound to play.
	 */
	var() SoundCue Sound;
	
	/**
	 * The time of day that the sound starts.  Enter a number between 0 and 23, corresponding to hours in a day.
	 */
	var() float StartTime;
	
	/**
	 * The time of day that the sound stops.  Enter a number between 0 and 23, corresponding to hours in a day.
	 */
	var() float EndTime;
};

/**
 * The list of sounds to play during a day/night cycle.
 */
var(Sound) array<AmbientSoundCue> Sounds;

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

/**
 * Indicates that the ambient sounce is muted.
 */
var bool Muted;


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
	local float ToD;
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
	
	ToD = 24 * WeatherManager.TimeOfDay / Pi;
	
	if (Sounds[CurrentSound].StartTime > ToD || Sounds[CurrentSound].EndTime < ToD)
		currAC.FadeOut(0.5, 0.0);
	
	for (i = 0; i < Sounds.Length; i++)
	{
		if (Sounds[i].StartTime < ToD && Sounds[i].EndTime > ToD && i != CurrentSound)
		{
			currAC.FadeOut(0.5, 0.0);
			nextAC.Stop();
			nextAC.SoundCue = Sounds[i].Sound;
			nextAC.FadeIn(0.5, Muted ? 0.0 : 1.0);
			CurrentSound = i;
			CurrentComponent = 1 - CurrentComponent;
		}
	}
}

simulated function Mute(float FadeOutTime)
{
	local AudioComponent currAC;
	
	if (Muted)
		return;
		
	if (CurrentComponent == 0)
		currAC = AudioComponent1;
	else
		currAC = AudioComponent2;
		
	currAC.AdjustVolume(FadeOutTime, 0.0);
	
	Muted = true;
}

simulated function Unmute(float FadeInTime)
{
	local AudioComponent currAC;
	
	if (!Muted)
		return;
		
	if (CurrentComponent == 0)
		currAC = AudioComponent1;
	else
		currAC = AudioComponent2;
		
	currAC.AdjustVolume(FadeInTime, 1.0);
	
	Muted = false;
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