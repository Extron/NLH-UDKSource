/*******************************************************************************
	ArenaFloor_PillarGridBuilder

	Creation date: 29/01/2014 13:13
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class ArenaFloor_PillarGridBuilder extends BrushBuilder;

event bool Build()
{
    FillGrid();
    return false;
}

function FillGrid()
{
    local WorldInfo WI;
    local ArenaFloor_PillarGrid iter;
	local ArenaFloor_PillarGrid grid;

    WI = class'Engine'.static.GetCurrentWorldInfo();
	
    foreach WI.AllActors(class'ArenaFloor_PillarGrid', iter)
    {
		if (grid == None)
			grid = iter;
	}
	
	if (grid == None)
	{
	}
	
	grid.CreateGrid();
}

defaultproperties
{
    BitmapFilename="PillarBuildIcon"
    ToolTip="Arena Floor Grid Builder"
}