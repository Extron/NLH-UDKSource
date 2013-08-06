/*******************************************************************************
	UI_Tower

	Creation date: 20/07/2013 13:33
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class UI_Tower extends DynamicSMActor;

var() const editconst StaticMeshComponent Wireframe;

var float TargetHeight;

var float OriginalHeight;

var float CurrentHeight;

var float MoveTime;

var float Counter;

var bool Moving;

function PostBeginPlay()
{
	super.PostBeginPlay();
	
	OriginalHeight = Location.Z;
	
	SetTimer(FRand() * 3, false, 'BeginMove');
}

function Tick(float dt)
{
	local vector newLoc;
	
	super.Tick(dt);
	
	if (Moving)
	{
		Counter += dt;
		
		newLoc = Location;
		newLoc.z = Lerp(CurrentHeight, TargetHeight, Counter / MoveTime);
		SetLocation(newLoc);
		
		if (Counter >= MoveTime)
		{
			Moving = false;
			SetTimer(FRand() * 10, false, 'BeginMove');
		}
	}
}

function BeginMove()
{
	Moving = true;
	
	CurrentHeight = Location.Z;
	
	TargetHeight = FRand() * 1536 * ((FRand() > 0.5) ? -1 : 1) + OriginalHeight;
	
	MoveTime = FRand() * 3 + 3;
	Counter = 0;
}

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent1
	    BlockRigidBody=false
		LightEnvironment=MyLightEnvironment
		bUsePrecomputedShadows=FALSE
	End Object
	Wireframe=StaticMeshComponent1
	Components.Add(StaticMeshComponent1)
}