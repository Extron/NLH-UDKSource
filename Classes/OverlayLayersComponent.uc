/*******************************************************************************
	OverlayLayersComponent

	Creation date: 25/12/2014 01:49
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

/**
 * This component will maintain a set of overlay meshes for actors to be dynamically added and removed from.
 */
class OverlayLayersComponent extends ActorComponent;

/**
 * Represents an overlay layer, which contains a mesh and an identifier.
 */
struct OverlayLayer
{
	/**
	 * The overlay mesh to draw.
	 */
	var MeshComponent Mesh;
	
	/**
	 * The name of the layer.
	 */
	var string LayerName;
};


/**
 * The current overlay layers.
 */
var array<OverlayLayer> Layers;


/**
 * Adds a new overlay layer to the owner of this component.
 */
function AddLayer(string layerName, MeshComponent mesh)
{
	local OverlayLayer layer;
	
	layer.LayerName = layerName;
	layer.Mesh = mesh;
	
	if (FindLayer(layerName) > -1)
		RemoveLayer(layerName);
		
	Owner.AttachComponent(layer.Mesh);
	Layers.AddItem(layer);
}

/**
 * Removes an overlay layer from the owner of this component.
 */
function RemoveLayer(string layerName)
{
	local int layer;
	
	layer = FindLayer(layerName);
	
	if (layer > -1)
	{
		Owner.DetachComponent(Layers[layer].Mesh);
		Layers.Remove(layer, 1);
	}
}

/**
 * Gets the index of the layer with the specified name.  Returns -1 if no layer was found.
 */
function int FindLayer(string layerName)
{
	local int i;
	
	for (i = 0; i < Layers.Length; i++)
	{
		if (Layers[i].LayerName == layerName)
			return i;
	}
	
	return -1;
}