/*******************************************************************************
	EnvironmentComponent

	Creation date: 25/12/2014 00:08
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

/**
 * This is a component that can be attached to actors to give them interactive properties for weather and abilities.
 */
class EnvironmentComponent extends ActorComponent;

/**
 * The properties to attach to the object.
 */
var(Properties) array<string> ObjectProperties;

/**
 * The scaling of the x coordinate of the mesh's UV coordinates.  Use this to tile the texture put onto it.  A value of zero 
 * means that the default material settings will be used.
 */
var(Properties) float MatUVXScale;

/**
 * The scaling of the y coordinate of the mesh's UV coordinates.  Use this to tile the texture put onto it.  A value of zero 
 * means that the default material settings will be used.
 */
var(Properties) float MatUVYScale;

/**
 * A static overlay mesh that can be used to draw the environment effects onto.
 */
var(Properties) StaticMesh StaticOverlayMesh<DisplayName=Static Overlay Mesh>;

/**
 * A skeletal overlay mesh that can be used to draw the environment effects onto.
 */
var(Properties) SkeletalMesh SkeletalOverlayMesh<DisplayName=Skeletal Overlay Mesh>;

/**
 * Indicates which mesh type to draw the environment effects on.
 */
var(Properties) bool UseStaticMesh;


