package  
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import scaleform.clik.data.DataProvider;
	import flash.external.ExternalInterface;
	
	public class WLSubmenu extends MovieClip 
	{
		public var componentUI:ComponentUI;
		public var baseUI:BaseUI;
		public var library:ComponentLibrary;
		public var description_label:DescriptionLabel;
		public var stats:s_stats;
		public var acceptButton:DefaultButton;
		public var cancelButton:DefaultButton;
		public var tooltip:s_part_tooltip;
		public var cursor:MenuCursor;
		public var background:Background;
		public var costLabel:CostLabel;
		public var tokenCount:Number;
		
		public function WLSubmenu() 
		{
		}
		
		public function AcceptButtonPressed(e:ButtonEvent)
		{
			ExternalInterface.call("AcceptButtonPressed");
		}
	}
}
