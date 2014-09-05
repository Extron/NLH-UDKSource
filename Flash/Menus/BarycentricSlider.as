package 
{
	import flash.display.MovieClip;
	import flash.geom.Vector3D;
	import flash.geom.Point;
	import flash.events.MouseEvent;
	import scaleform.clik.controls.Button;
	
	public class BarycentricSlider extends MovieClip
	{
		public var coordinates:Vector3D;
		public var point1:Point;
		public var point2:Point;
		public var point3:Point;
		public var slider:Button;

		var invDet:Number;
		
		public function get CartesianCoordinates():Point
		{
			var point = new Point();
			
			point.x = point1.x * coordinates.x + point2.x * coordinates.y + point3.x * coordinates.z;
			point.y = point1.y * coordinates.x + point2.y * coordinates.y + point3.y * coordinates.z;
			
			return point;
		}
		
		public function set CartesianCoordinates(value:Point)
		{
			coordinates.x = invDet * ((point2.y - point3.y) * (value.x - point3.x) - (point2.x - point3.x) * (value.y - point3.y));
			coordinates.y = invDet * ((point3.y - point1.y) * (value.x - point3.x) - (point3.x - point1.x) * (value.y - point3.y));
			coordinates.z = 1.0 - coordinates.x - coordinates.y;
			
			slider.x = CartesianCoordinates.x;
			slider.y = CartesianCoordinates.y;
			
			var event:BarycentricSliderEvent = new BarycentricSliderEvent(BarycentricSliderEvent.SLIDER_MOVED);
			event.coordinates = coordinates;
			
			dispatchEvent(event);
		}
		
		
		public function BarycentricSlider()
		{
			coordinates = new Vector3D();
			coordinates.x = 1.0 / 3.0;
			coordinates.y = 1.0 / 3.0;
			coordinates.z = 1.0 / 3.0;
			
			point1 = new Point(0, 111);
			point2 = new Point(64, 0);
			point3 = new Point(128,111);
			
			invDet = 1.0 / ((point2.y - point3.y) * (point1.x - point3.x) + (point3.x - point2.x) * (point1.y - point3.y));
			addEventListener(MouseEvent.MOUSE_MOVE, SetSlider);
			addEventListener(MouseEvent.CLICK, SetSlider);
		}
		
		function IsInTriangle(point:Point):Boolean
		{
			var x = invDet * ((point2.y - point3.y) * (point.x - point3.x) - (point2.x - point3.x) * (point.y - point3.y));
			var y = invDet * ((point3.y - point1.y) * (point.x - point3.x) - (point3.x - point1.x) * (point.y - point3.y));
			var z = 1.0 - x - y;

			return (x >= 0 && x <= 1) && (y >= 0 && y <= 1) && (z >= 0 && z <= 1);
		}
		
		function SetSlider(e:MouseEvent)
		{
				
			if ((e.buttonDown && e.type == MouseEvent.MOUSE_MOVE) || e.type == MouseEvent.CLICK)
			{
				var mousePoint:Point;
				
				if (e.target != this && e.target is MovieClip)
					mousePoint = globalToLocal(MovieClip(e.target).localToGlobal(new Point(e.localX, e.localY)));
				else
					mousePoint = new Point(e.localX, e.localY);
				
				if (IsInTriangle(mousePoint))
					CartesianCoordinates = mousePoint;
			}
		}
	}
}