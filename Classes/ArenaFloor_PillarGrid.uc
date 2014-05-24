/*******************************************************************************
	ArenaFloor_PillarGrid

	Creation date: 11/01/2014 12:00
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * This class maintains the pillar grid, spawning pillars as needed.
 */
class ArenaFloor_PillarGrid extends Actor;


/**
 * The pillars that make up the grid.
 */
var array<ArenaFloor_Pillar> Pillars;

/**
 * The number of rings of pillars to make about the center.
 */
var(PillarGrid) int Radius;

/**
 * The radius of each pillar.
 */
var(PillarGrid) float PillarRadius;

/**
 * The size of the gap between pillars.
 */
var(PillarGrid) float GapSize;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	
	UpdateGridLighting();
}

simulated function UpdateGridLighting()
{
	local int i;

	for (i = 0; i < Pillars.Length; i++)
	{
		if (Pillars[i] != None)
		{
			//`log("Initializing pillar" @ Pillars[i]);
			Pillars[i].UpdateLighting();
			
			if (Pillars[i].RandomMotion)
				Pillars[i].InitializeRandomMotion();
		}
	}
}

simulated function CreateGrid()
{
	local ArenaFloor_Pillar pillar;
	local float w;
	local int r;
	local int theta;
	local int z;
	
	w = 2 * PillarRadius * Sin(1.0472) + GapSize;
	
	//Spawn the center pillar.
	pillar = Spawn(class'Arena.ArenaFloor_Pillar', self, , Location);
	Pillars.AddItem(pillar);

	for (r = 1; r < Radius; r++)
	{
		for (theta = 0; theta < 6; theta++)
		{
			for (z = 0; z < r; z++)
			{
				pillar = Spawn(class'Arena.ArenaFloor_Pillar', self, , Location + r * w * RotatedVector(theta) + z * w * RotatedVector(theta + 2));
				Pillars.AddItem(pillar);
			}
		}
	}
}

function vector RotatedVector(float theta)
{
	local vector v;
	
	v.x = Cos(theta * 1.0472);
	v.y = Sin(theta * 1.0472);
	
	return v;
}

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=SM
		StaticMesh = StaticMesh'AO_ArenaFloor.Meshes.PillarEdWireframe'
		Scale3D=(X=1,Y=1,Z=1)
		bCastDynamicShadow=false
		CastShadow=false
		HiddenGame=true
	End Object
	
	Begin Object Class=EditorComponent Name=EC
		DepthPriorityGroup=SDPG_UnrealEdBackground

		bDrawGrid=true
		bDrawPivot=true
		bDrawBaseInfo=true
		GridColorHi=(R=0,G=0,B=127)
		GridColorLo=(R=0,G=0,B=63)
		PerspectiveGridSize=262143.0 
		bDrawWorldBox=true
		bDrawColoredOrigin=false
		bDrawKillZ=true

		PivotColor=(R=255,G=0,B=0)
		PivotSize=0.02

		BaseBoxColor=(R=0,G=255,B=0)
	End Object

	Components.Add(SM)
	Components.Add(EC)
	
	CollisionComponent=SM
	
	bStatic=true
	Radius=4
	PillarRadius=96
	GapSize=0.1
}