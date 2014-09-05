package 
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.display.Loader;
	import flash.display.Bitmap;
	import flash.net.URLRequest;
	
	import scaleform.clik.data.DataProvider;
	import scaleform.clik.events.ListEvent;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.controls.Button;
	
	public class ComponentList extends MovieClip
	{
		public var componentList:DefaultScrollingList;
		public var scrollBar:DefaultScrollBar;
		public var componentNameTextfield:TextField;
		public var descriptionTextfield:TextField;
		public var strengthsTextfield:TextField;
		public var weaknessesTextfield:TextField;
		public var energyTextfield:TextField;
		public var costTextfield:TextField;
		public var equipButton:DefaultButton;
		public var cancelButton:DefaultButton;
		
		public var loader:Loader;
		public var image:Bitmap;
		
		var selectedComponent:int;
		
		
		public function set ComponentName(value:String) { componentNameTextfield.text = value; }
		public function set ComponentDescription(value:String) { descriptionTextfield.text = value; }
		
		public function set ComponentStrengths(value:Array) 
		{ 
			strengthsTextfield.text = "Strengths: ";
			
			for (var i = 0; i < value.length; i++)
			{
				strengthsTextfield.appendText(value[i]);
				
				if (i < value.length - 1)
					strengthsTextfield.appendText(", ");
			}
		}
		
		public function set ComponentWeaknesses(value:Array) 
		{ 
			weaknessesTextfield.text = "Weaknesses: ";
			
			for (var i = 0; i < value.length; i++)
			{
				weaknessesTextfield.appendText(value[i]);
				
				if (i < value.length - 1)
					weaknessesTextfield.appendText(", ");
			}
		}
		
		public function set ComponentEnergyCost(value:Number) { energyTextfield.text = "Energy Cost: " + String(value); }
		public function set ComponentCost(value:Number) { costTextfield.text = "Cost: " + String(value); }
		
		public function set SelectedComponent(value:int)
		{
			if (value >= 0 && value < componentList.dataProvider.length)
			{
				selectedComponent = value;
				
				PopulateDisplay(componentList.dataProvider[selectedComponent]);
			}
			else
			{
				DisplayVisible = false;
				equipButton.enabled = false;
			}
		}
		
		public function set DisplayVisible(value:Boolean)
		{
			componentNameTextfield.visible = value;
			descriptionTextfield.visible = value;
			strengthsTextfield.visible = value;
			weaknessesTextfield.visible = value;
			energyTextfield.visible = value;
			costTextfield.visible = value;
			
			ClearImage();
		}
		
		
		public function ComponentList()
		{
			selectedComponent = -1;
			DisplayVisible = false;
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, LoadComplete, false, 0 , true);
			
			cancelButton.addEventListener(ButtonEvent.CLICK, Cancel);
			
			componentList.addEventListener(ListEvent.INDEX_CHANGE, ChangeSelectedComponent);
		}
		
		public function FillList(components:Array, selectedComponent:int)
		{
			componentList.dataProvider = new DataProvider(components);
			SelectedComponent = selectedComponent;
		}
		
	 	function PopulateDisplay(component:Object)
		{
			DisplayVisible = true;
			
			if ("name" in component) ComponentName = component.name;
			if ("description" in component) ComponentDescription = component.description;
			if ("strengths" in component) ComponentStrengths = component.strengths;
			if ("weaknesses" in component) ComponentWeaknesses = component.weaknesses;
			if ("energy" in component) ComponentEnergyCost = component.energy;
			if ("cost" in component) ComponentCost = component.cost;
			if ("imgSrc" in component) LoadImage(component.imgSrc);
			
			if ("owned" in component)
			{
				if (component.owned)
				{
					equipButton.label = "Equip";
					equipButton.removeEventListener(ButtonEvent.CLICK, PurchaseComponent);
					equipButton.addEventListener(ButtonEvent.CLICK, EquipComponent);
				}
				else
				{
					equipButton.label = "Purchase";
					equipButton.removeEventListener(ButtonEvent.CLICK, EquipComponent);
					equipButton.addEventListener(ButtonEvent.CLICK, PurchaseComponent);
				}
			}
			
			equipButton.enabled = true;
		}
		
		function LoadImage(imgSrc:String)
		{
			var urlReq:URLRequest = new URLRequest(imgSrc);
			loader.load(urlReq);
		}
		
		function ClearImage()
		{
			if (image != null) removeChild(image);
		}
		
		function LoadComplete(event:Event):void
		{
			image = Bitmap(loader.content);
			image.x = -128;
			image.y = 320;
			image.width = 256;
			image.height = 256;
			
			addChild(image);
		}
		
		function ChangeSelectedComponent(e:ListEvent)
		{
			SelectedComponent = e.index;
		}
		
		function EquipComponent(e:ButtonEvent)
		{
			trace("EquipButton pressed");
			var event:ComponentListEvent = new ComponentListEvent(ComponentListEvent.EQUIP_COMPONENT);
			event.selectedComponent = selectedComponent;
			
			dispatchEvent(event);
		}
		
		function PurchaseComponent(e:ButtonEvent)
		{
			var event:ComponentListEvent = new ComponentListEvent(ComponentListEvent.PURCHASE_COMPONENT);
			event.selectedComponent = selectedComponent;
			
			/*componentList.dataProvider[selectedComponent].owned = true;
			componentList.invalidateData();
			PopulateDisplay(componentList.dataProvider[selectedComponent]);*/
			
			dispatchEvent(event);
		}
		
		function Cancel(e:ButtonEvent)
		{
			var event:ComponentListEvent = new ComponentListEvent(ComponentListEvent.CANCEL);
			event.selectedComponent = -1;
			
			dispatchEvent(event);
		}
	}
}