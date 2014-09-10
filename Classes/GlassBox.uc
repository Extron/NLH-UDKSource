/*******************************************************************************
	GlassBox

	Creation date: 08/09/2014 09:10
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

class GlassBox extends Actor placeable;

/**
 * The structural actors that need to be rotated when the box is rotated.
 */
var array<Actor> Structures;

/**
 * Keep track of actor starting positions to help rotate them later.
 */
var array<vector> DefaultActorPositions;

/**
 * Keep track of the actor starting rotations to help rotate them properly later.
 */
var array<rotator> DefaultActorOrientations;

/**
 * The world point around which the box should rotate.
 */
var (GlassBox) vector Origin;

/**
 * The current level rotation.
 */
var rotator CurrentBoxRotation;

/**
 * The desired level rotation.
 */
var rotator DesiredBoxRotation;

/**
 * The starting level rotation prior to rotating the box.
 */
var rotator StartingBoxRotation;

/**
 * The time it will take to rotate to the desired rotation.
 */
var float RotationTime;

/**
 * The counter to keep track of rotation for the level.
 */
var float Counter;

simulated function PostBeginPlay()
{
	local Actor iter;
	
	super.PostBeginPlay();
	
	foreach AllActors(class'Actor', iter)
	{
		if (InStr(string(iter.Tag), "GB_") > -1)
		{
			Structures.Additem(iter);
			DefaultActorPositions.AddItem(iter.Location);
			DefaultActorOrientations.AddItem(iter.Rotation);
		}
	}
}

simulated function Tick(float dt)
{
	local Actor iter;
	
	super.Tick(dt);
	
	if (Counter < RotationTime)
	{
		CurrentBoxRotation = RLerp(StartingBoxRotation, DesiredBoxRotation, Counter / RotationTime);

		foreach Structures(iter)
		{
			RotateAboutPoint(iter, Origin, CurrentBoxRotation);
		}
		
		Counter += dt;
		
		if (Counter >= RotationTime)
			EndRotation();
	}
}

simulated function RotateAboutPoint(Actor actor, vector rotOrigin, rotator newRot)
{
	local matrix rotMat;
	
	rotMat = MakeRotationMatrix(DefaultActorOrientations[Structures.Find(actor)]) * MakeRotationMatrix(newRot);
	
	if (actor.CollisionComponent != None)
	{
		actor.CollisionComponent.SetRBPosition(((DefaultActorPositions[Structures.Find(actor)] - rotOrigin) >> newRot) + rotOrigin);
		actor.CollisionComponent.SetRBRotation(MatrixGetRotator(rotMat));
	}
	else
	{
		actor.SetLocation(((DefaultActorPositions[Structures.Find(actor)] - rotOrigin) >> newRot) + rotOrigin);
		actor.SetRotation(MatrixGetRotator(rotMat));
	}
}

simulated function BeginRotation()
{
	local int i;
	
	for (i = 0; i < Structures.Length; i++)
	{
		if (InterpActor(Structures[i]) != None && Structures[i].CollisionComponent !=  None)
		{
			Structures[i].SetPhysics(PHYS_RigidBody);
		}
	}
}

simulated function EndRotation()
{
	local int i;
	
	for (i = 0; i < Structures.Length; i++)
	{
		if (InterpActor(Structures[i]) != None && Structures[i].CollisionComponent !=  None)
			Structures[i].SetPhysics(PHYS_None);
	}
}

simulated function SetDesiredRotation(SeqAct_GBSetDesiredRotation seqAct)
{
	StartingBoxRotation = CurrentBoxRotation;
	DesiredBoxRotation.Pitch = int(seqAct.DesiredRotation.x);
	DesiredBoxRotation.Yaw = int(seqAct.DesiredRotation.y);
	DesiredBoxRotation.Roll = int(seqAct.DesiredRotation.z);

	RotationTime = seqAct.RotationTime;
	Counter = 0;
	BeginRotation();
}

defaultproperties
{
	Begin Object Class=DrawBoxComponent Name=DrawBox
		DepthPriorityGroup=SDPG_UnrealEdBackground
		
		BoxColor=(R=255,G=255,B=0,A=255)
		BoxExtent=(X=1480,Y=1480,Z=1480)
		bDrawWireBox=true
	End Object
	Components.Add(DrawBox)
}