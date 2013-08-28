package
{
	import flash.display.MovieClip;
	import scaleform.clik.controls.ListItemRenderer;
    import scaleform.clik.data.ListData;
    import flash.text.TextField;
	
	public class WeaponLibraryListItemRenderer extends ListItemRenderer 
	{
		public var cost:TextField;
		public var costLabel:String;
		public var grayOut:Boolean;
		
		[Inspectable(defaultValue="")]
        public function get CostLabel():String { return costLabel; }
        public function set CostLabel(value:String):void {
            if (costLabel == value) { return; }
            costLabel = value;
            invalidateData();
        }
		
		[Inspectable(defaultValue="")]
        public function get GrayOut():Boolean { return grayOut; }
        public function set GrayOut(value:Boolean):void {
            if (grayOut == value) { return; }
            grayOut = value;
            invalidateData();
        }
		
		public function WeaponLibraryListItemRenderer() 
		{
			CostLabel = "";
		}
		
		protected override function updateText():void 
		{
            if (_label != null && textField != null)
                textField.text = _label;
			
			if (costLabel != null && cost != null)
				cost.text = costLabel;
				
			if (grayOut && textField != null)
				textField.textColor = 0x555555;
        }
		
		public override function setListData(listData:ListData):void 
		{
            index = listData.index;
            selected = listData.selected;
			label = "";
			
			if (data != null)
			{
				if ("name" in data)
					label = data.name || "";
				else
					label = "";
					
				if ("cost" in data && "purchased" in data && !data.purchased)
					CostLabel = String(data.cost) + " T";
				else
					CostLabel = "";
					
				if ("purchased" in data && !data.purchased)
					GrayOut = true;
				else
					GrayOut = false;
			}
        }
	}
}
