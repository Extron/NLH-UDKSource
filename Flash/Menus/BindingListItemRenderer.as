package  
{
	import flash.display.MovieClip;
	import scaleform.clik.controls.ListItemRenderer;
	import scaleform.clik.data.ListData;
	import flash.text.TextField;
	
	public class BindingListItemRenderer extends ListItemRenderer
	{
		public var command:TextField;
		public var commandLabel:String;
		public var binding:TextField;
		public var bindingLabel:String;
		
		[Inspectable(defaultValue="")]
        public function get CommandLabel():String { return commandLabel; }
        public function set CommandLabel(value:String):void 
		{
            if (commandLabel == value) { return; }
            commandLabel = value;
            invalidateData();
        }
		
		[Inspectable(defaultValue="")]
        public function get BindingLabel():String { return bindingLabel; }
        public function set BindingLabel(value:String):void 
		{
            if (bindingLabel == value) { return; }
            bindingLabel = value;
            invalidateData();
        }
		
		
		public function BindingListItemRenderer() 
		{
			CommandLabel = "";
			BindingLabel = "";
		}
		
		protected override function updateText():void 
		{			
			if (commandLabel != null && command != null)
				command.text = commandLabel;
				
			if (bindingLabel != null && binding != null)
				binding.text = bindingLabel;
        }
		
		public override function setListData(listData:ListData):void 
		{
            index = listData.index;
            selected = listData.selected;
			
			if (data != null)
			{
				if ("command" in data)
					CommandLabel = data.command || "";
				else
					CommandLabel = "";
					
				if ("binding" in data)
					BindingLabel = data.binding || "";
				else
					BindingLabel = "";
			}
        }
	}
}
