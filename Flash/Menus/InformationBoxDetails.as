package 
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import scaleform.clik.events.ButtonEvent;
	import flash.events.Event;
	
	public class InformationBoxDetails extends MovieClip
	{
		protected var tabButtons:Array;
		protected var selectedTab:Number;
		public var initialTab:String;
		
		public function InformationBoxDetails()
		{
			tabButtons = new Array();
			
			addEventListener(Event.ADDED_TO_STAGE, OnAddedToStage);
			
			for (var i = 0; i < numChildren; i++)
			{
				var child = getChildAt(i);
				
				if (child is TabButton)
				{
					var tabButton = child as TabButton;
					tabButton.addEventListener(ButtonEvent.CLICK, SwitchTabs);
					tabButtons.push(tabButton);
				}
			}
		}
		
		public function SetData(data:Object):void
		{
		}
		
		protected function SetTabContents():void
		{
		}
		
		function SwitchTabs(e:ButtonEvent)
		{
			var tabButton = e.currentTarget as TabButton;
			
			tabButtons[selectedTab].enabled = true;
			tabButton.enabled = false;
			selectedTab = tabButtons.indexOf(tabButton);
			
			SetTabContents();
		}
		
		function OnAddedToStage(e:Event):void 
		{
			var leftTab = -1;
			var i = 0;
			
			for (i = 0; i < tabButtons.length; i++)
			{
				if (tabButtons[i].label == initialTab)
				{
					leftTab = i;
					break;
				}
			}
			
			if (leftTab > -1)
			{
				selectedTab = leftTab;
				tabButtons[selectedTab].enabled = false;
				
				SetTabContents();
				return;
			}
			
			leftTab = 0;
			
			for (i = 0; i < tabButtons.length; i++)
			{
				if (tabButtons[i].x < tabButtons[leftTab].x)
					leftTab = i;
			}
			
			selectedTab = leftTab;
			tabButtons[selectedTab].enabled = false;
			
			SetTabContents();
		}
	}
}