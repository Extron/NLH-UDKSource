package
{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import scaleform.clik.managers.PopUpManager;
	
	public class MainMenu extends MovieClip
	{
		public var titleLabel:TitleLabel;
		public var version:DefaultLabel;
		public var buttons:MainButtons;
		public var popupWindow:DefaultWindow;
		public var popupTinter:Tinter;
		public var cursor:MenuCursor;
		
		public function MainMenu() 
		{
			PopUpManager.init(Stage(parent));
		}
	}
}
