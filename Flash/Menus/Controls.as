package  
{
	
	import flash.display.MovieClip;
	
	
	public class Controls extends MovieClip 
	{
		public var menuTitle:TitleLabel;
		public var saveButton:DefaultButton;
		public var cancelButton:DefaultButton;
		public var cursor:MouseCursor;
		public var list1:DefaultScrollingList;
		public var list2:DefaultScrollingList;
		public var listBackground1:ListBackground;
		public var listBackground2:ListBackground;
		public var keyPrompt:KeyPrompt;
		public var interceptKey:Boolean;
		public var activeBinding:Number;
		public var activeList:Number;
		
		public function Controls() 
		{
		}
	}
	
}
