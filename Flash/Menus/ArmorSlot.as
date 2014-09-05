package 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.display.Loader;
	import flash.display.Bitmap;
	import flash.net.URLRequest;
	import flash.external.ExternalInterface;
	import scaleform.clik.events.ButtonEvent;
	
	public class ArmorSlot extends MovieClip
	{
		public var slotName:TextField;
		public var componentName:TextField;
		public var energyCostLabel:TextField;
		public var equipButton:DefaultButton;
		public var loader:Loader;
		public var image:Bitmap;
		
		public function set SlotName(name:String) { slotName.text = name;  equipButton.label = (componentName.text == "Empty" ? "Equip " : "Change ") + SlotName};
		public function get SlotName():String { return slotName.text; }
		
		public function ArmorSlot()
		{
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, LoadComplete, false, 0 , true);
			
			componentName.text = "Empty";
			energyCostLabel.text = "";
			
			equipButton.addEventListener(ButtonEvent.CLICK, EquipSlot);
		}

		public function EquipArmor(armor:Object)
		{
			componentName.text = armor.name;
			
			if (armor.energyCost > 0)
				energyCostLabel.text = "Energy Cost: " + armor.energyCost;
			else
				energyCostLabel.text = "";
				
			equipButton.label = "Change " + SlotName;
			
			LoadImage(armor.icon);
		}
		
		public function ClearArmor(armor:Object)
		{
			componentName.text = "Empty";
			energyCostLabel.text = "";
			equipButton.label = "Equip " + SlotName;
			ClearImage();
		}
		
		function LoadImage(imgSrc:String)
		{
			var urlReq:URLRequest = new URLRequest(imgSrc);
			loader.load(urlReq);
		}
		
		function ClearImage()
		{
			removeChild(image);
		}
		
		function LoadComplete(event:Event):void
		{
			image = Bitmap(loader.content);
			image.x = 32;
			image.y = 16;
			image.width = 128;
			image.height = 64;
			
			addChild(image);
		}
		
		function EquipSlot(e:ButtonEvent)
		{
			if (ExternalInterface.available) ExternalInterface.call("EquipSlot", SlotName);
		}
	}

}