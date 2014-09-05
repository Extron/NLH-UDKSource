package 
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.display.Loader;
	import flash.display.Bitmap;
	import flash.net.URLRequest;

	import scaleform.clik.controls.ListItemRenderer;
	import scaleform.clik.data.ListData;

	public class ComponentListItemRenderer extends ListItemRenderer
	{
		public var nameTextfield:TextField;
		public var costTextfield:TextField;
		public var imageTint:ComponentImageTint;
		
		public var loader:Loader;
		public var image:Bitmap;
		
		var componentName:String;
		var componentCost:Number;
		
		public function set ComponentName(value:String) { componentName = value; nameTextfield.text = value; }
		public function get ComponentName():String { return componentName; }
		
		public function set ComponentCost(value:Number) { componentCost = value; costTextfield.text = "Cost: " + String(value); }
		public function get ComponentCost():Number { return componentCost; }
		
		public function set Owned(value:Boolean)
		{
			if (value)
			{
				costTextfield.visible = false;
				imageTint.visible = false;
			}
			else
			{
				costTextfield.visible = true;
				imageTint.visible = true;
			}
		}
		
		public function ComponentListItemRenderer()
		{
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, LoadComplete, false, 0 , true);
			
			ComponentName = "";
			ComponentCost = 0;
		}
		
		protected override function updateText():void 
		{
            if (nameTextfield != null)
			{
                if (componentName != null) nameTextfield.text = componentName;
				else nameTextfield.text = "";
			}
			
			if (componentCost != 0 && costTextfield != null)
			{
				if (componentCost > 0) costTextfield.text = "Cost: " + String(componentCost);
				else costTextfield.text == "";
			}
        }
		
		public override function setListData(listData:ListData):void 
		{
            index = listData.index;
            selected = listData.selected;
			
			trace(this + " Data " + data);
			
			if (data != null)
			{
				nameTextfield.visible = true;
				costTextfield.visible = true;
				imageTint.visible = true;
				
				if ("name" in data)
					ComponentName = data.name || "";
				else
					ComponentName = "";
					
				if ("cost" in data)
					ComponentCost = data.cost || 0;
				else
					ComponentCost = 0;
					
				if ("owned" in data)
					Owned = data.owned;
				else
					Owned = false;
					
				if ("imgSrc" in data)
					LoadImage(data.imgSrc);
			}
			else
			{
				nameTextfield.visible = false;
				costTextfield.visible = false;
				imageTint.visible = false;
			}
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
			image.x = imageTint.x;
			image.y = imageTint.y;
			image.width = imageTint.width;
			image.height = imageTint.height;
			
			addChild(image);
		}
	}
}