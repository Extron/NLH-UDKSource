package 
{
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
		
	import scaleform.clik.controls.Window;
	
	public class DefaultWindow extends Window
	{
        public function get content():DisplayObject { return _content; }
		
		public function DefaultWindow() 
		{
		}
	}
	
}
