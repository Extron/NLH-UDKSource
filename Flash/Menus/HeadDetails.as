package 
{
	import flash.display.MovieClip;


	public class HeadDetails extends InformationBoxDetails
	{
		public var modifyFeaturesButton:DefaultButton;
		public var eyeSlot:ArmorSlot;
		public var helmetSlot:ArmorSlot;
		
		public function HeadDetails()
		{
			eyeSlot.SlotName = "Eye Implants";
			helmetSlot.SlotName = "Helmet";
		}
		
		public override function SetData(data:Object):void
		{
			if (data.hasOwnProperty("eyeImplants")) eyeSlot.EquipArmor(data.eyeImplants);
			if (data.hasOwnProperty("helmet")) helmetSlot.EquipArmor(data.helmet);
		}
	}
}