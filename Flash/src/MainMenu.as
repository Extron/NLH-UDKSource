package 
{	
	import flash.display.MovieClip;
	import flash.ui.Mouse;
	
	/**
	 * ...
	 * @author Trystan Binkley-Jones
	 */
	public class MainMenu
	{		
		static var mainMenu:MainMenu;
		
		static function main(mc:MovieClip):void
		{
			mainMenu = new MainMenu();
		}
		
		public function MainMenu()
		{
			Mouse.hide();
		}		
	}
	
}