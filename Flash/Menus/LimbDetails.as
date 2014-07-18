﻿package 
{
	import flash.display.MovieClip;

	public class LimbDetails extends InformationBoxDetails
	{
		public var limbSlot:ArmorSlot;
		public var upperArmorSlot:ArmorSlot;
		public var lowerArmorSlot:ArmorSlot;
		
		var limbName:String;
		
		public function set LimbName(name:String)
		{
			limbName = name;
			
			limbSlot.SlotName = limbName;
			
			if (name.indexOf("Arm") > -1)
			{
				upperArmorSlot.SlotName = "Upper Arm Armor";
				lowerArmorSlot.SlotName = "Forearm Armor";
			}
			else if (name.indexOf("Leg") > -1)
			{
				upperArmorSlot.SlotName = "Thigh Armor";
				lowerArmorSlot.SlotName = "Calf Armor";
			}
		}
		
		public function get LimbName():String { return limbName; }
		
		public function LimbDetails()
		{
		}
		
		public override function SetData(data:Object):void
		{
			if (data.hasOwnProperty("limbName")) LimbName = data.limbName;
			if (data.hasOwnProperty("limb")) limbSlot.EquipArmor(data.limb);
			if (data.hasOwnProperty("upperArmor")) upperArmorSlot.EquipArmor(data.upperArmor);
			if (data.hasOwnProperty("lowerArmor")) lowerArmorSlot.EquipArmor(data.lowerArmor);
		}
	}
}