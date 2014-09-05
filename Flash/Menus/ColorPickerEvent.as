package 
{
	import flash.events.Event;
	
	public class ColorPickerEvent extends Event
	{
		public static const COLOR_CHANGED = "colorChanged";
		public static const PALETTE_CLOSED = "paletteClosed";
		
		var color:uint;

		public function set Color(value:uint) { color = value; }
		public function get Color():uint { return color; }
		
		public function ColorPickerEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}