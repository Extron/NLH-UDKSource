package
{
	import flash.display.MovieClip;
	
	public class Graphics extends MovieClip
	{
		public var menuTitle:TitleLabel;
		public var saveButton:DefaultButton;
		public var cancelButton:DefaultButton;
		public var cursor:MouseCursor;
		public var listBackground1:ListBackground;
		public var listBackground2:ListBackground;
		public var keyPrompt:KeyPrompt;
		public var interceptKey:Boolean;
		public var activeBinding:Number;
		public var activeList:Number;
		public var leftPanel:LeftPanel;
		public var rightPanel:RightPanel;
		
		public function Graphics()
		{
		}
	}
}
