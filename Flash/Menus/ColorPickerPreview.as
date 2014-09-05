package 
{
	import flash.display.MovieClip;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import scaleform.clik.events.ButtonEvent;
	import scaleform.clik.controls.Button;
	
	public class ColorPickerPreview extends Button
	{
		public var previewBox:ColorPreviewBox;
		public var colorList:Array;
		public var selectedColor:int;
		public var colorPalette:ColorPickerPalette;
		
		public function set PreviewColor(value:uint)
		{
			var colorTransform:ColorTransform = previewBox.transform.colorTransform;
			colorTransform.color = value;
			previewBox.transform.colorTransform = colorTransform;
			
			var event:ColorPickerEvent = new ColorPickerEvent(ColorPickerEvent.COLOR_CHANGED);
			event.Color = value;
			
			dispatchEvent(event);
		}
		
		public function get PreviewColor():uint
		{
			return previewBox.transform.colorTransform.color;
		}
		
		public function set SelectedColor(value:int)
		{
			if (value >= 0 && value < colorList.length)
			{
				selectedColor = value;
				PreviewColor = parseInt(colorList[selectedColor], 16);
			}
		}
		
		public function set PaletteGridWidth(value:Number) { colorPalette.gridWidth = value; }
		public function get PaletteGridWidth():Number { return colorPalette.gridWidth; }
		
		public function set PaletteGridHeight(value:Number) { colorPalette.gridHeight = value; }
		public function get PaletteGridHeight():Number { return colorPalette.gridHeight; }
		
		public function set PaletteCellWidth(value:Number) { colorPalette.cellWidth = value; }
		public function get PaletteCellWidth():Number { return colorPalette.cellWidth; }
		
		public function set PaletteCellHeight(value:Number) { colorPalette.cellHeight = value; }
		public function get PaletteCellHeight():Number { return colorPalette.cellHeight; }
		
		public function ColorPickerPreview()
		{
			colorPalette = new ColorPickerPalette();
			colorPalette.x = x + 4;
			colorPalette.y = y + height + 4;
			colorPalette.addEventListener(ColorPickerEvent.COLOR_CHANGED, CloseColorPalette);
			colorPalette.addEventListener(ColorPickerEvent.PALETTE_CLOSED, CloseColorPalette);
			
			colorPalette.visible = false;
			
			toggle = false;
			addEventListener(ButtonEvent.CLICK, OpenColorPalette);
		}
		
		function OpenColorPalette(e:ButtonEvent)
		{
			parent.addChild(colorPalette);
			colorPalette.visible = true;
			colorPalette.FillPalette(colorList);
			stage.focus = colorPalette;
		}
		
		function CloseColorPalette(e:ColorPickerEvent)
		{
			colorPalette.visible = false;
			parent.removeChild(colorPalette);
			
			var colorNumericList:Array = new Array();
			
			for (var i = 0; i < colorList.length; i++)
				colorNumericList.push(parseInt(colorList[i]));
			
			trace("Event type " + e.type);
			
			if (e.type == ColorPickerEvent.COLOR_CHANGED)
				SelectedColor = colorNumericList.indexOf(e.Color);
		}
	}
}