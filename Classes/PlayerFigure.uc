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
 * The list of armor that the player is wearing.
 */
var array<ArmorComponent> Armor;

/**
 * The list of weapons the player has equipped.
 */
var array<ArenaWeapon> Weapons;

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

/**
 * The index of the armor component (should be an arm) that is holding the held weapon.
 */
var int HoldingArm;

simulated function LoadFigure(LoadoutData figureLoadout, ArenaPlayerController controller, optional bool drawInForeground = true)
{
	local ArenaWeapon newWeapon;
	local ArmorComponent armorComponent;
	local int i;
	
	DetachArmor();
	ClearWeapons();
	
	Loadout.SetLoadout(figureLoadout, controller);

	if (Loadout != None && Loadout.Armor != None)
	{
		for (i = 0; i < Loadout.Armor.Components.Length; i++)
		{
			armorComponent = Spawn(Loadout.Armor.Components[i], self);
			armorComponent.MeshComponent.SetLightEnvironment(LightEnvironment);
			
			if (drawInForeground)
				armorComponent.MeshComponent.SetDepthPriorityGroup(SDPG_Foreground);
				
			armorComponent.MeshComponent.SetOnlyOwnerSee(false);
			
			AttachArmor(armorComponent);
			
			if (armorComponent.Type == ACTRightArm)
				HoldingArm = i;
		}
	}
	
	if (Loadout != None && Loadout.PrimaryWeapon != None)
	{
		newWeapon = CreateWeapon(Loadout.PrimaryWeapon, drawInForeground);
		newWeapon.SetOwner(self);
		newWeapon.AttachWeaponTo(Armor[HoldingArm].MeshComponent, 'HandSocket');
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
			iter.Mesh.SetDepthPriorityGroup(SDPG_Foreground);
			iter.Mesh.SetOnlyOwnerSee(false);
		}
	}
	
	return ArenaWeaponBase;
}

simulated function AttachArmor(ArmorComponent armorComponent)
{
	Armor.AddItem(armorComponent);
	AttachComponent(armorComponent.MeshComponent);
}

simulated function DetachArmor()
{
	local ArmorComponent iter;
	
	foreach Armor(iter)
	{
		iter.Destroy();
	}
	
	Armor.Length = 0;
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
	local ArmorComponent armorIter;
	local ArenaWeapon weaponIter;
	
	foreach Armor(armorIter)
		armorIter.MeshComponent.SetScale(scale);
		
	foreach Weapons(weaponIter)
		weaponIter.SetWeaponScale(scale);
}

defaultproperties
{
	Begin Object Class=PlayerLoadout Name=DefaultLoadout
	End Object
	Loadout=DefaultLoadout
}