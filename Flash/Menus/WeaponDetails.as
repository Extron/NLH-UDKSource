package 
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.external.ExternalInterface;
	
	import scaleform.clik.events.ButtonEvent;

	public class WeaponDetails extends InformationBoxDetails
	{
		public var editWeaponButton:DefaultButton;
		public var openLibraryButton:DefaultButton;
		public var generalTabButton:TabButton;
		public var componentsTabButton:TabButton;
		public var appearanceTabButton:TabButton;
		public var weaponType:TextField;
		
		var weaponComponents:Array;
		var attributes:Array;
		
		public function WeaponDetails()
		{
			weaponComponents = new Array();
			attributes = new Array();
			
			editWeaponButton.addEventListener(ButtonEvent.CLICK, OnEditWeaponButtonClicked, false, 0, true);
			openLibraryButton.addEventListener(ButtonEvent.CLICK, OnOpenLibraryButtonClicked, false, 0, true);
		}
		
		protected override function SetTabContents():void
		{
			var i = 0;
			
			for (i = 0; i < weaponComponents.length; i++)
			{
				weaponComponents[i].visible = false;
			}
			
			for (i = 0; i < attributes.length; i++)
			{
				attributes[i].visible = false;
			}
			
			weaponType.visible = false;
			
			switch (tabButtons[selectedTab].label)
			{
			case "General":
				weaponType.visible = true;
				
				for (i = 0; i < attributes.length; i++)
				{
					attributes[i].visible = true;
				}
				break;
				
			case "Components":
				for (i = 0; i < weaponComponents.length; i++)
				{
					weaponComponents[i].visible = true;
				}
				break;
				
			case "Appearance":
				break;
			}
		}
		
		public override function SetData(data:Object):void
		{
			if (data.hasOwnProperty("parts")) CreateComponents(data.parts as Array);
			if (data.hasOwnProperty("type")) weaponType.text = "Weapon Type: " + data.type;
			if (data.hasOwnProperty("attributes")) CreateAttributes(data.attributes as Array);
			
			SetTabContents();
		}
		
		private function CreateComponents(parts:Array)
		{
			var component:WeaponComponent;
			
			var attachmentCount = 0;
			var partCount = 0;
			
			for (var i = 0; i < parts.length; i++)
			{
				component = new WeaponComponent();
				
				component.SetData(parts[i]);
				component.width = 192;
				component.height = 64;
				
				if ("attachment" in parts[i] && parts[i].attachment)
				{
					component.x = 0;
					component.y = (64 + 8) * attachmentCount + 24;
					attachmentCount++;
				}
				else
				{
					component.x = -192;
					component.y = (64 + 8) * partCount + 24;
					partCount++;
				}
				
				addChild(component);
				weaponComponents.push(component);
			}
		}
		
		private function CreateAttributes(data:Array)
		{
			var attribute:AttributeDisplay;
			
			var count = 0;
			
			for (var i = 0; i < data.length; i++)
			{
				attribute = new AttributeDisplay();
				
				attribute.statName.text = data[i].name;
				attribute.valueLabel.text = data[i].value;
				
				attribute.width = 384;
				attribute.height = 24;
				attribute.x = -192;
				attribute.y = 64 + 24 * count;
				
				count++;
				
				addChild(attribute);
				attributes.push(attribute);
			}
		}
		
		private function OnEditWeaponButtonClicked(e:ButtonEvent)
		{
			if (ExternalInterface.available) ExternalInterface.call("DetailsButtonPressed", "Edit Weapon");
		}
		
		private function OnOpenLibraryButtonClicked(e:ButtonEvent)
		{
			if (ExternalInterface.available) ExternalInterface.call("DetailsButtonPressed", "Open Library");
		}
	}
}