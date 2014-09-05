package 
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;

	public class ColorPreviewBox extends MovieClip
	{
		public var colorDisplay:ColorDisplay;
		
		public function set Color(color:ColorTransform)
		{
			colorDisplay.transform.colorTransform = color;
		}
		
		public function get Color():ColorTransform
		{
			return colorDisplay.transform.colorTransform;
		}
		
		public function ColorPreviewBox()
		{
			addEventListener(MouseEvent.ROLL_OVER, Highlight);
			addEventListener(MouseEvent.ROLL_OUT, DeHighlight);
		}
		
		function Highlight(e:MouseEvent)
		{
			gotoAndPlay("over");
		}
		
		function DeHighlight(e:MouseEvent)
		{
			gotoAndPlay("up");
		}
	}
}