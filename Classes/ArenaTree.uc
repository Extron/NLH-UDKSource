/*******************************************************************************
	ArenaTree

	Creation date: 21/05/2013 01:07
	Copyright (c) 2013, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaTree extends SpeedTreeActor
	placeable;

/** 
 * A reference to the material that the actor uses. 
 */
var Array<MaterialInstanceConstant> BranchMaterials;

/**
 * The material to use for the leaves of the tree.
 */
var MaterialInstanceConstant LeafMat;

/**
 * Stores the level of the snow on the object, which increases when it snows and decreases when it is hot.
 */
var float SnowLevel;

/**
 * Stores the level of rain water on the object, which increases when it rains, decreases when it is hot, 
 * and becomes ice when it is cold.
 */
var float RainLevel;

/**
 * Indicates that the object should be frozen.
 */
var bool Frozen;


simulated function PostBeginPlay()
{
	local MaterialInstanceConstant mat;
	local Texture Diffuse, Normal, Specular, Height;
	
	super.PostBeginPlay();
	
	mat = new class'MaterialInstanceConstant';
	mat.SetParent(SpeedTreeComponent.GetMaterial(STMT_Branches1));
	
	mat.GetTextureParameterValue('Diffuse', Diffuse);
	mat.GetTextureParameterValue('NormalMap', Normal);
	mat.GetTextureParameterValue('Specular', Specular);
	mat.GetTextureParameterValue('Heightmap', Height);
	
	SpeedTreeComponent.SetMaterial(STMT_Branches1, mat);
	BranchMaterials.AddItem(mat);
	
	mat = new class'MaterialInstanceConstant';
	mat.SetParent(Material'ArenaMaterials.Materials.SnowMat');
	mat.SetTextureParameterValue('Diffuse', Diffuse);
	mat.SetTextureParameterValue('NormalMap', Normal);
	mat.SetTextureParameterValue('Specular', Specular);
	mat.SetTextureParameterValue('Heightmap', Height);
	BranchMaterials.AddItem(mat);
	
	mat = new class'MaterialInstanceConstant';
	mat.SetParent(Material'ArenaMaterials.Materials.RainMat');
	mat.SetTextureParameterValue('Diffuse', Diffuse);
	mat.SetTextureParameterValue('NormalMap', Normal);
	mat.SetTextureParameterValue('Specular', Specular);
	mat.SetTextureParameterValue('Heightmap', Height);
	BranchMaterials.AddItem(mat);
	
	
	mat = new class'MaterialInstanceConstant';
	mat.SetParent(SpeedTreeComponent.GetMaterial(STMT_Branches2));
	
	mat.GetTextureParameterValue('Diffuse', Diffuse);
	mat.GetTextureParameterValue('NormalMap', Normal);
	mat.GetTextureParameterValue('Specular', Specular);
	mat.GetTextureParameterValue('Heightmap', Height);
	
	SpeedTreeComponent.SetMaterial(STMT_Branches2, mat);
	BranchMaterials.AddItem(mat);
	
	mat = new class'MaterialInstanceConstant';
	mat.SetParent(Material'ArenaMaterials.Materials.SnowMat');
	mat.SetTextureParameterValue('Diffuse', Diffuse);
	mat.SetTextureParameterValue('NormalMap', Normal);
	mat.SetTextureParameterValue('Specular', Specular);
	mat.SetTextureParameterValue('Heightmap', Height);
	BranchMaterials.AddItem(mat);
	
	mat = new class'MaterialInstanceConstant';
	mat.SetParent(Material'ArenaMaterials.Materials.RainMat');
	mat.SetTextureParameterValue('Diffuse', Diffuse);
	mat.SetTextureParameterValue('NormalMap', Normal);
	mat.SetTextureParameterValue('Specular', Specular);
	mat.SetTextureParameterValue('Heightmap', Height);
	BranchMaterials.AddItem(mat);

	LeafMat = new class'MaterialInstanceConstant';
	LeafMat.SetParent(SpeedTreeComponent.GetMaterial(STMT_LeafCards));
	SpeedTreeComponent.SetMaterial(STMT_LeafCards, LeafMat);
}

simulated function Tick(float dt)
{
	super.Tick(dt);
	
	if (ArenaGRI(WorldInfo.GRI) != None && ArenaGRI(WorldInfo.GRI).WeatherMgr != None)
	{
		if (FastTrace(Location + vect(0, 0, 1000)))
		{
			if (ArenaGRI(WorldInfo.GRI).WeatherMgr.Snowing)
				SnowLevel += dt * ArenaGRI(WorldInfo.GRI).WeatherMgr.WeatherIntensity * ArenaGRI(WorldInfo.GRI).WeatherMgr.SnowBuildupRate;
			else if (ArenaGRI(WorldInfo.GRI).WeatherMgr.Thawing)
				SnowLevel -= dt * ArenaGRI(WorldInfo.GRI).WeatherMgr.Temperature * ArenaGRI(WorldInfo.GRI).WeatherMgr.SnowBuildupRate;
			
			if (ArenaGRI(WorldInfo.GRI).WeatherMgr.Raining)
				RainLevel += dt * ArenaGRI(WorldInfo.GRI).WeatherMgr.WeatherIntensity * ArenaGRI(WorldInfo.GRI).WeatherMgr.RainBuildupRate;
			else
				RainLevel -= dt * ArenaGRI(WorldInfo.GRI).WeatherMgr.WeatherIntensity * ArenaGRI(WorldInfo.GRI).WeatherMgr.RainBuildupRate;
			
			SnowLevel = FClamp(SnowLevel, 0.0, 1.0);
			RainLevel = FClamp(RainLevel, 0.0, 1.0);

			if (SnowLevel > 0)
			{
				SpeedTreeComponent.SetMaterial(STMT_Branches1, BranchMaterials[1]);
				BranchMaterials[1].SetScalarParameterValue('WeatherLevel', SnowLevel > 0 ? SnowLevel : RainLevel);
				
				SpeedTreeComponent.SetMaterial(STMT_Branches2, BranchMaterials[4]);
				BranchMaterials[4].SetScalarParameterValue('WeatherLevel', SnowLevel > 0 ? SnowLevel : RainLevel);
			}
			else if (RainLevel > 0)
			{
				SpeedTreeComponent.SetMaterial(STMT_Branches1, BranchMaterials[2]);
				BranchMaterials[5].SetScalarParameterValue('WeatherLevel', SnowLevel > 0 ? SnowLevel : RainLevel);
				
				SpeedTreeComponent.SetMaterial(STMT_Branches2, BranchMaterials[5]);
				BranchMaterials[5].SetScalarParameterValue('WeatherLevel', SnowLevel > 0 ? SnowLevel : RainLevel);
			}
			else
			{
				SpeedTreeComponent.SetMaterial(STMT_Branches1, BranchMaterials[0]);
				SpeedTreeComponent.SetMaterial(STMT_Branches2, BranchMaterials[3]);
			}
			
			LeafMat.SetScalarParameterValue('Temperature', ArenaGRI(WorldInfo.GRI).WeatherMgr.Temperature);
			
			SpeedTreeComponent.SpeedTree.WindStrength = VSize(ArenaGRI(WorldInfo.GRI).WeatherMgr.Wind);
			SpeedTreeComponent.SpeedTree.WindDirection = Normal(ArenaGRI(WorldInfo.GRI).WeatherMgr.Wind);
		}
	}

	
}

defaultproperties
{
	bStatic=false
}