package 
{
	import flash.events.Event;
	import flash.geom.Vector3D;
	
	public class BarycentricSliderEvent extends Event
	{
		public static const SLIDER_MOVED = "Barycentric slider moved";
		
		var coordinates:Vector3D;
		
		public function BarycentricSliderEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}