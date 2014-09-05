package 
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.events.FocusEvent;

	public class ColorPickerPalette extends MovieClip
	{
		public var gridWidth:Number;
		public var gridHeight:Number;
		public var cellWidth:Number;
		public var cellHeight:Number;
		
		public function ColorPickerPalette()
		{
			addEventListener(FocusEvent.FOCUS_OUT, LostFocus);
		}
		
		public function FillPalette(colors:Array)
		{
			for (var i = 0; i < gridWidth; i++)
			{
				for (var j = 0; j < gridHeight; j++)
				{
					if (j * gridWidth + i >= colors.length)
						return;
						
					var cell:ColorPreviewBox = new ColorPreviewBox();
					
					cell.width = cellWidth;
					cell.height = cellHeight;
					cell.x = i * cellWidth;
					cell.y = j * cellHeight;
					
					var colorTransform:ColorTransform = cell.Color;
					colorTransform.color = colors[j * gridWidth + i];
					cell.Color = colorTransform;

					cell.addEventListener(MouseEvent.CLICK, ColorSelected);
					addChild(cell);
				}
			}
		}
		
		function ColorSelected(e:MouseEvent)
		{
			var event:ColorPickerEvent = new ColorPickerEvent(ColorPickerEvent.COLOR_CHANGED);
			event.Color = MovieClip(e.currentTarget).Color.color;
			
			dispatchEvent(event);
		}
		
		function LostFocus(e:FocusEvent)
		{
			var event:ColorPickerEvent = new ColorPickerEvent(ColorPickerEvent.PALETTE_CLOSED);
			
			var i;
			var loseFocus:Boolean = true;
			
			for (i = 0; i < numChildren; i++)
			{
				var child:MovieClip = MovieClip(getChildAt(i));

				if (child is ColorPreviewBox && child.currentLabel == "over")
					loseFocus = false;
			}
			
			if (loseFocus)
				dispatchEvent(event);
		}
	}
}