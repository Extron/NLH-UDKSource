package 
{
	import flash.display.MovieClip;

	public class HeadDetails extends InformationBoxDetails
	{
		public var modifyFeaturesButton:DefaultButton;
		public var eyeSlot:ArmorSlot;
		public var helmetSlot:ArmorSlot;
		public var modTabButton:TabButton;
		public var featuresTabButton:TabButton;
		public var clothesTabButton:TabButton;
		public var featuresDetails:FacialFeaturesDetails;
		
		public function HeadDetails()
		{
			eyeSlot.SlotName = "Eye Implants";
			helmetSlot.SlotName = "Helmet";
			
			featuresDetails.visible = false;
		}
		
		public override function SetData(data:Object):void
		{
			if (data.hasOwnProperty("eyeImplants")) eyeSlot.EquipArmor(data.eyeImplants);
			if (data.hasOwnProperty("helmet")) helmetSlot.EquipArmor(data.helmet);
			if (data.hasOwnProperty("facialFeatures")) featuresDetails.SetData(data.facialFeatures);
		}
		
		protected override function SetTabContents():void
		{
			switch (tabButtons[selectedTab].label)
			{
			case "Mods":
				eyeSlot.visible = true;
				helmetSlot.visible = true;
				featuresDetails.visible = false;
				break;
				
			case "Features":
				eyeSlot.visible = false;
				helmetSlot.visible = false;
				featuresDetails.visible = true;
				break;
				
			case "Clothes":
				eyeSlot.visible = false;
				helmetSlot.visible = false;
				featuresDetails.visible = false;
				break;
			}
		}
	}
}