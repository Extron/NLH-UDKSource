package 
{
	import flash.display.MovieClip;

	public class ArmorDetails extends InformationBoxDetails
	{
		public function ArmorDetails()
		{
		}
		
		public override function SetData(data:Object):void
		{
			
		}
		
		function AddArmorSlot(slotName:String)
		{
			var slot:ArmorSlot = new ArmorSlot();
			
			slot.SlotName = slotName;
			
			slot.x = 0;
			slot.y = numChildren * (96 + 16);
			
			addChild(slot);
		}
	}
}