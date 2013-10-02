package
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.Loader;
	import flash.display.Bitmap;

	import scaleform.clik.controls.ListItemRenderer;
    import scaleform.clik.data.ListData;
	import scaleform.clik.events.InputEvent;
	import flash.net.URLRequest;
	
	public class AbilityItemRenderer extends ListItemRenderer
	{
		public var ability:TextField;
		public var cost:TextField;
		public var cooldown:TextField;
		public var description:TextField;
		
		public var abilityLabel:String;
		public var costLabel:String;
		public var cooldownLabel:String;
		public var descLabel:String;
		
		public var deleteButton:DeleteListButton;
				
		public var loader:Loader;
		public var image:Bitmap;
		
		
		[Inspectable(defaultValue="")]
        public function get AbilityLabel():String { return abilityLabel; }
		
        public function set AbilityLabel(value:String):void 
		{
            if (abilityLabel == value) { return; }
			
            abilityLabel = value;
            invalidateData();
        }
		
		[Inspectable(defaultValue="")]
        public function get CostLabel():String { return costLabel; }
		
        public function set CostLabel(value:String):void 
		{
            if (costLabel == value) { return; }
			
            costLabel = value;
            invalidateData();
        }
		
		[Inspectable(defaultValue="")]
        public function get CooldownLabel():String { return cooldownLabel; }
		
        public function set CooldownLabel(value:String):void 
		{
            if (cooldownLabel == value) { return; }
			
            cooldownLabel = value;
            invalidateData();
        }
		
		[Inspectable(defaultValue="")]
        public function get DescLabel():String { return descLabel; }
		
        public function set DescLabel(value:String):void 
		{
            if (descLabel == value) { return; }
			
            descLabel = value;
            invalidateData();
        }
		
		
		public function AbilityItemRenderer()
		{
				abilityLabel = "";
				costLabel = "";
				cooldownLabel = "";
				descLabel = "";
				
				loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, LoadComplete, false, 0 , true);
		}
		
		protected override function updateText():void 
		{
            if (abilityLabel != null && ability != null)
                ability.text = abilityLabel;
			
			if (costLabel != null && cost != null)
				cost.text = costLabel;
						
			if (cooldownLabel != null && cooldown != null)
				cooldown.text = cooldownLabel;	
				
			if (descLabel != null && description != null)
				description.text = descLabel;
        }
		
		public override function setListData(listData:ListData):void 
		{
            index = listData.index;
            selected = listData.selected;
			
			if (data != null)
			{
				if ("ability" in data)
					AbilityLabel = data.ability || "";
				else
					AbilityLabel = "";
					
				if ("cost" in data)
					CostLabel = "EC: " + String(data.cost);
				else
					CostLabel = "";
					
				if ("cooldown" in data)
					CooldownLabel = "Cooldown: " + String(data.cooldown) + " s";
				else
					CooldownLabel = "";
					
				if ("description" in data)
					DescLabel = data.description || "";
				else
					DescLabel = "";
					
				if ("imgSrc" in data)
					LoadImage(data.imgSrc);
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
			image.x = 256;
			image.y = 0;
			image.width = 128;
			image.height = 128;
			
			addChild(image);
		}
	}
}
