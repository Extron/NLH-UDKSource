/*******************************************************************************
	BBWaveManager

	Creation date: 29/12/2012 14:39
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class BBWaveManager extends Actor
	placeable;

/** Specifies what each individual wave contains. */
var(Properties) array<BBWaveComponent> Waves;

/** The time between waves. */
var(Properties) float IntermissionTime;

/** Indicates that a new wave will begin once intermission is over.  If this is false, the
    wave needs to be started manually. */
var(Properties) bool AutoBegin;

/** The current wave. */
var int CurrentWave;

/** The parent game info that owns this wave manager. */
var GI_BotBattle Parent;

/**
 * Indicates that we are currently in intermission.
 */
var bool Intermission;

simulated function Tick(float dt)
{
	if (CurrentWave >= 0 && CurrentWave < Waves.Length)
	{
		Waves[CurrentWave].UpdateWave();
	
		if (CurrentWaveComplete() && !Intermission)
		{
			`log("Wave complete.");
			
			Intermission = true;
			
			Parent.WaveComplete(Waves[CurrentWave]);
			
			if (AutoBegin)
				SetTimer(IntermissionTime, false, 'SpawnNextWave');
		}
	}
}

simulated function Initialize(GI_BotBattle gameInfo)
{
	local BBWaveComponent wave;
	
	Parent = gameInfo;
	
	foreach Waves(wave)
	{
		wave.Initialize(self);
	}
}

simulated function SpawnNextWave()
{
	if (Intermission)
	{
		CurrentWave++;
		Intermission = false;
		
		if (CurrentWave < Waves.Length)
		{
			`log("Spawning new wave.");
			
			Waves[CurrentWave].SpawnWave();
			Parent.WaveSpawned(Waves[CurrentWave]);
		}
	}
}

/**
 * Gets whether the current wave is complete or not.
 */
simulated function bool CurrentWaveComplete()
{
	if (!AllWavesComplete())
		return Waves[CurrentWave].Complete;
	else
		return true;
}

/**
 * Gets whether all of the waves are complete or not.
 */
simulated function bool AllWavesComplete()
{
	return CurrentWave >= Waves.Length;
}

defaultproperties
{
	CurrentWave=-1
	IntermissionTime=5
	Intermission=true
	AutoBegin=true
}