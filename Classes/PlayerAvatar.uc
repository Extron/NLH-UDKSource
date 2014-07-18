/*******************************************************************************
	PlayerAvatar

	Creation date: 16/07/2014 00:03
	Creator: Trystan
	Copyright (c) 2014, Strange Box Software
*******************************************************************************/

/**
 * Contains all of the 3D meshes needed to draw the player's avatar in the game.
 */
class PlayerAvatar extends Actor
	dependson(BodyPartComponent, ArmorComponent, ClothingComponent);

/**
 * The player pawn that owns this avatar.
 */
var AP_Player Pawn;

/**
 * The body parts that are used to draw the core part of the player.
 */
var array<BodyPartComponent> BodyParts;

/**
 * The armor parts that the player is wearing.
 */
var array<ArmorComponent> Armor;

/**
 * The clothing that the player is wearing.
 */
var array<ClothingComponent> Clothes;

simulated function Destroyed()
{
	local int i;
	
	for (i = 0; i < BodyParts.Length; i++)
		BodyParts[i].Destroy();
		
	for (i = 0; i < Armor.Length; i++)
		Armor[i].Destroy();
		
	for (i = 0; i < Clothes.Length; i++)
		Clothes[i].Destroy();
		
	BodyParts.Length = 0;
	Armor.Length = 0;
	Clothes.Length = 0;
}

function LoadAvatar(AvatarSchematic schematic)
{
	local BodyPartComponent bodyPart;
	local ArmorComponent armorPart;
	local ClothingComponent clothing;
	local ArmorAttachment armorAttachment;
	local int i;
	
	for (i = 0; i < schematic.BodyParts.Length; i++)
	{
		bodyPart = Spawn(schematic.BodyParts[i], Pawn);
		
		BodyParts.AddItem(bodyPart);

		Pawn.AttachComponent(bodyPart.MeshComponent);
		Pawn.AddStatMod(bodyPart.StatMod);
	}
	
	for (i = 0; i < schematic.Armor.Length; i++)
	{
		armorPart = Spawn(schematic.Armor[i], Pawn);
		
		Armor.AddItem(armorPart);

		Pawn.AttachComponent(armorPart.MeshComponent);
		Pawn.AddStatMod(armorPart.StatMod);
	}
	
	for (i = 0; i < schematic.Clothing.Length; i++)
	{
		clothing = Spawn(schematic.Clothing[i], Pawn);
		
		Clothes.AddItem(clothing);

		Pawn.AttachComponent(clothing.MeshComponent);
		Pawn.AddStatMod(clothing.StatMod);
	}
	
	for (i = 0; i < schematic.Attachments.Length; i++)
	{
		armorAttachment = Spawn(schematic.Attachments[i], self);
		
		for (i = 0; i < BodyParts.Length; i++)
		{
			if (BodyParts[i].Type == armorAttachment.AttachComponentType)
			{
				BodyParts[i].AttachArmor(armorAttachment);
				break;
			}
		}
		
	}
	
	AddAnimationSet(ArenaPlayerController(Pawn.Controller).PClass.AbilityAnimSet);
}

function LoadFigureAvatar(PlayerFigure figure, AvatarSchematic schematic, optional bool drawInForeground = true)
{
	local BodyPartComponent bodyPart;
	local ArmorComponent armorPart;
	local ClothingComponent clothing;
	local ArmorAttachment armorAttachment;
	local int i;
	
	for (i = 0; i < schematic.BodyParts.Length; i++)
	{
		bodyPart = Spawn(schematic.BodyParts[i], figure);
		
		if (drawInForeground)
			bodyPart.MeshComponent.SetDepthPriorityGroup(SDPG_Foreground);
				
		bodyPart.MeshComponent.SetOnlyOwnerSee(false);
		
		BodyParts.AddItem(bodyPart);

		figure.AttachComponent(bodyPart.MeshComponent);
	}
	
	for (i = 0; i < schematic.Armor.Length; i++)
	{
		armorPart = Spawn(schematic.Armor[i], figure);
		
		if (drawInForeground)
			armorPart.MeshComponent.SetDepthPriorityGroup(SDPG_Foreground);
			
		armorPart.MeshComponent.SetOnlyOwnerSee(false);
		
		Armor.AddItem(armorPart);

		figure.AttachComponent(armorPart.MeshComponent);
	}
	
	for (i = 0; i < schematic.Clothing.Length; i++)
	{
		clothing = Spawn(schematic.Clothing[i], figure);
		
		if (drawInForeground)
				clothing.MeshComponent.SetDepthPriorityGroup(SDPG_Foreground);
				
		clothing.MeshComponent.SetOnlyOwnerSee(false);
		
		Clothes.AddItem(clothing);

		figure.AttachComponent(clothing.MeshComponent);
	}
	
	for (i = 0; i < schematic.Attachments.Length; i++)
	{
		armorAttachment = Spawn(schematic.Attachments[i], self);
		
		if (drawInForeground)
			armorAttachment.MeshComponent.SetDepthPriorityGroup(SDPG_Foreground);
		
		armorAttachment.MeshComponent.SetOnlyOwnerSee(false);
		
		for (i = 0; i < BodyParts.Length; i++)
		{
			if (BodyParts[i].Type == armorAttachment.AttachComponentType)
			{
				BodyParts[i].AttachArmor(armorAttachment);
				break;
			}
		}
		
	}
}

simulated function SetTranslation(vector translation)
{
	local int i;
	
	for (i = 0; i < BodyParts.Length; i++)
		BodyParts[i].MeshComponent.SetTranslation(translation);
		
	for (i = 0; i < Armor.Length; i++)
		Armor[i].MeshComponent.SetTranslation(translation);
		
	for (i = 0; i < Clothes.Length; i++)
		Clothes[i].MeshComponent.SetTranslation(translation);
}

simulated function SetScale(float scale)
{
	local int i;
	
	for (i = 0; i < BodyParts.Length; i++)
		BodyParts[i].MeshComponent.SetScale(scale);
		
	for (i = 0; i < Armor.Length; i++)
		Armor[i].MeshComponent.SetScale(scale);
		
	for (i = 0; i < Clothes.Length; i++)
		Clothes[i].MeshComponent.SetScale(scale);
}

simulated function PlayAnimation(name sequence, optional float duration, optional bool loop, optional float blendIn, optional float blendOut, optional bool uninterruptable = false)
{
	local int i;
	
	for (i = 0; i < BodyParts.Length; i++)
		BodyParts[i].PlayAnimation(sequence, duration, loop, blendIn, blendOut);
		
	for (i = 0; i < Armor.Length; i++)
		Armor[i].PlayAnimation(sequence, duration, loop, blendIn, blendOut);
		
	for (i = 0; i < Clothes.Length; i++)
		Clothes[i].PlayAnimation(sequence, duration, loop, blendIn, blendOut);
}

function AddAnimationSet(AnimSet animSet)
{
	local int i;
	
	for (i = 0; i < BodyParts.Length; i++)
		BodyParts[i].MeshComponent.AnimSets.AddItem(animSet);
		
	for (i = 0; i < Armor.Length; i++)
		Armor[i].MeshComponent.AnimSets.AddItem(animSet);
		
	for (i = 0; i < Clothes.Length; i++)
		Clothes[i].MeshComponent.AnimSets.AddItem(animSet);
}

function SetFOV(float angle)
{
	local int i;

	for (i = 0; i < BodyParts.Length; i++)
		BodyParts[i].SetFOV(angle);
		
	for (i = 0; i < Armor.Length; i++)
		Armor[i].SetFOV(angle);
		
	for (i = 0; i < Clothes.Length; i++)
		Clothes[i].SetFOV(angle);
}