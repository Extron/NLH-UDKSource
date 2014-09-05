/*******************************************************************************
	PlayerFigure

	Creation date: 26/03/2014 07:47
	Copyright (c) 2014, Trystan
	<!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

/**
 * A player figure is used to showcase character and weapon models for things like menus.
 */
class PlayerFigure extends Actor;


/**
 * The list of weapons the player has equipped.
 */
var array<ArenaWeapon> Weapons;

/**
 * The player's avatar.
 */
var PlayerAvatar Avatar;

/**
 * The loadout used to define the figure.
 */
var PlayerLoadout Loadout;

/**
 * The light environment used to display the figure.
 */
var DynamicLightEnvironmentComponent LightEnvironment;

/**
 * The index of the weapon the player is holding.
 */
var int HeldWeapon;

simulated function Destroyed()
{
	if (Avatar != None)
		Avatar.Destroy();
}

simulated function LoadFigure(LoadoutData figureLoadout, ArenaPlayerController controller, optional bool drawInForeground = true)
{
	local ArenaWeapon newWeapon;
	
	DetachArmor();
	ClearWeapons();
	
	Loadout.SetLoadout(figureLoadout, controller);

	Avatar = Spawn(class'Arena.PlayerAvatar', self);
	
	if (Loadout != None && Loadout.Avatar != None)
	{
		Avatar.LoadFigureAvatar(self, Loadout.Avatar, drawInForeground);
	}
	
	if (Loadout != None && Loadout.PrimaryWeapon != None)
	{
		newWeapon = CreateWeapon(Loadout.PrimaryWeapon, drawInForeground);
		newWeapon.SetOwner(self);
		newWeapon.AttachWeaponTo(Avatar.BodyParts[BPTRightArm].MeshComponent, 'HandSocket');
		Weapons.AddItem(newWeapon);
	}
	
	HeldWeapon = 0;
}

function ArenaWeapon CreateWeapon(WeaponSchematic schematic, bool drawInForeground)
{
	local ArenaWeaponBase ArenaWeaponBase;
	local ArenaWeaponComponent iter;
	local Wp_Stock stock;
	local Wp_Barrel barrel;
	local Wp_Muzzle muzzle;
	local Wp_Optics optics;
	local Wp_SideAttachment side;
	local Wp_UnderAttachment under;
	
	ArenaWeaponBase = spawn(schematic.ArenaWeaponBase, Self, , Location, Rotation);
	ArenaWeaponBase.WeaponName = schematic.WeaponName;
	
	stock = spawn(schematic.WeaponStock, ArenaWeaponBase, , ArenaWeaponBase.Location, ArenaWeaponBase.Rotation);
	barrel = spawn(schematic.WeaponBarrel, ArenaWeaponBase, , ArenaWeaponBase.Location, ArenaWeaponBase.Rotation);
	muzzle = spawn(schematic.WeaponMuzzle, ArenaWeaponBase, , ArenaWeaponBase.Location, ArenaWeaponBase.Rotation);
	optics = spawn(schematic.WeaponOptics, ArenaWeaponBase, , ArenaWeaponBase.Location, ArenaWeaponBase.Rotation);
	side = spawn(schematic.WeaponSideAttachment, ArenaWeaponBase, , ArenaWeaponBase.Location, ArenaWeaponBase.Rotation);
	under = spawn(schematic.WeaponUnderAttachment, ArenaWeaponBase, , ArenaWeaponBase.Location, ArenaWeaponBase.Rotation);
	
	ArenaWeaponBase.AttachStock(stock);
	ArenaWeaponBase.AttachBarrel(barrel);
	ArenaWeaponBase.AttachMuzzle(muzzle);
	ArenaWeaponBase.AttachOptics(optics);
	ArenaWeaponBase.AttachSide(side);
	ArenaWeaponBase.AttachUnder(under);
	
	ArenaWeaponBase.SetFireModes(schematic.WeaponFireModes);
	
	if (drawInForeground)
	{
		ArenaWeaponBase.Mesh.SetDepthPriorityGroup(SDPG_Foreground);
		
		foreach ArenaWeaponBase.WeaponComponents(iter)
		{
			iter.SetDepthPriorityGroup(SDPG_Foreground);
			iter.Mesh.SetOnlyOwnerSee(false);
		}
	}
	
	return ArenaWeaponBase;
}

simulated function ReattachWeapon()
{
	Weapons[HeldWeapon].AttachWeaponTo(Avatar.BodyParts[BPTRightArm].MeshComponent, 'HandSocket');
}

simulated function DetachArmor()
{
	if (Avatar != None)
		Avatar.Destroy();
}

simulated function ClearWeapons()
{
	local ArenaWeapon iter;
	
	foreach Weapons(iter)
	{
		iter.Destroy();
	}
	
	Weapons.Length = 0;
}

simulated function SetFigureScale(float scale)
{
	local ArenaWeapon weaponIter;

	Avatar.SetScale(scale);
		
	foreach Weapons(weaponIter)
		weaponIter.SetWeaponScale(scale);
}

simulated function SetFigureDrawScale(float scale)
{
	local ArenaWeapon weaponIter;
	local ArenaWeaponComponent componentIter;
	
	SetDrawScale(scale);
	Avatar.SetAvatarDrawScale(scale);
	
	foreach Weapons(weaponIter)
	{
		foreach ArenaWeaponBase(weaponIter).WeaponComponents(componentIter)
			componentIter.SetWeaponScale(scale);
	}
}

simulated function SetFigureTranslation(vector translation)
{
	Avatar.SetTranslation(translation);
}

defaultproperties
{
	Begin Object Class=PlayerLoadout Name=DefaultLoadout
	End Object
	Loadout=DefaultLoadout
}