/*******************************************************************************
	Optics

	Creation date: 07/07/2012 14:57
	Copyright (c) 2012, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class Wp_Optics extends ArenaWeaponComponent;

/**
 * Some sights, such as iron sites, have two parts, a rear sight and a post sight.
 * This mesh component is for the post sight, while the ArenaWeaponComponent member MeshComponent is 
 * used for the rear sights.
 */
var MeshComponent PostSightMeshComponent;

var name PostSocket;
var bool OnlyZoomWeapon;
var bool LineUpPost;


simulated function AttachToBase(ArenaWeaponBase weap, name socket)
{
	super.AttachToBase(weap, socket);

	if (PostSightMeshComponent == None)
		return;

	if (SkeletalMeshComponent(weap.WeaponComponents[WCBarrel].Mesh).GetSocketByName(PostSocket) != None)
		SkeletalMeshComponent(weap.WeaponComponents[WCBarrel].Mesh).AttachComponentToSocket(PostSightMeshComponent, PostSocket);
	else
		SkeletalMeshComponent(weap.Mesh).AttachComponentToSocket(PostSightMeshComponent, PostSocket);
		
	PostSightMeshComponent.SetLightEnvironment(ArenaPawn(weap.Instigator).LightEnvironment);
	//PostSightMeshComponent.SetScale3D(Mesh.Scale3D);
}

simulated function AttachToBaseSpecial(ArenaWeaponBase weap, name socket, LightEnvironmentComponent lightEnv)
{
	local vector rearLocation, postLocation;
	local rotator rearRotation, postRotation;
	
	super.AttachToBaseSpecial(weap, socket, lightEnv);

	if (PostSightMeshComponent == None)
		return;
		
	weap.GetOpticsPostSocketLocRot(PostSocket, postLocation, postRotation);
	weap.GetOpticsSocketLocRot(rearLocation, rearRotation);
	
	if (SkeletalMeshComponent(weap.WeaponComponents[WCBarrel].Mesh).GetSocketByName(PostSocket) != None)
		SkeletalMeshComponent(weap.WeaponComponents[WCBarrel].Mesh).AttachComponentToSocket(PostSightMeshComponent, PostSocket);
	else
		SkeletalMeshComponent(weap.Mesh).AttachComponentToSocket(PostSightMeshComponent, PostSocket);
		
	//SkeletalMeshComponent(weap.WeaponComponents[WCBarrel].Mesh).AttachComponentToSocket(PostSightMeshComponent, PostSocket);
	PostSightMeshComponent.SetLightEnvironment(lightEnv);
}

simulated function bool CanAttachToBase(ArenaWeaponBase baseWeap)
{
	return super.CanAttachToBase(baseWeap) && baseWeap.CanEquipOptics(self);
}

function vector GetOpticsOffset(vector l, rotator r)
{
	local vector socketLoc;
	local vector v;
	local rotator socketRot;

	if (SkeletalMeshComponent(Mesh) != None && SkeletalMeshComponent(Mesh).GetSocketByName('SightSocket') != None)
	{
		if (SkeletalMeshComponent(Mesh).GetSocketWorldLocationAndRotation('SightSocket', socketLoc, socketRot, 0))
		{
			v = (socketLoc - l) << r;

			v.y = v.x;
			v.x = 0;
			
			if (LineUpPost)
				v += Wp_Barrel(WeaponBase.WeaponComponents[WCBarrel]).SightsOffset;
		}
	}
	
	return v;
}

/**
 * Allows weapon optics to modify things like depth of field when the player aims down sights.
 */
simulated function BlurADS(UberPostProcessEffect effect)
{
}

simulated function SetComponentFOV(float angle)
{
	super.SetComponentFOV(angle);
	
	if (PostSightMeshComponent != None)
		UDKSkeletalMeshComponent(PostSightMeshComponent).SetFOV(angle);
}

simulated function SetWeaponScale(float scale)
{
	super.SetWeaponScale(scale);
	
	if (PostSightMeshComponent != None)
		PostSightMeshComponent.SetScale(scale);
}

defaultproperties
{
	Begin Object Class=UDKSkeletalMeshComponent Name=PostMesh
		DepthPriorityGroup=SDPG_PostProcess
		bOnlyOwnerSee=true
		bOverrideAttachmentOwnerVisibility=true
		bCastDynamicShadow=false
		CastShadow=false
		bOwnerNoSee=false
	End Object
	PostSightMeshComponent=PostMesh
	
	PostSocket=PostSightSocket
	
	Subclasses[0]=class'Arena.Wp_O_NoOptics'
	Subclasses[1]=class'Arena.Wp_O_VIronSights'
	Subclasses[2]=class'Arena.Wp_O_AcogScope'
}