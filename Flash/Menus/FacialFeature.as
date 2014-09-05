package 
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.external.ExternalInterface;
	import scaleform.clik.controls.ListItemRenderer;
	import scaleform.clik.data.ListData;
	import scaleform.clik.events.SliderEvent;
	import flash.events.Event;

	public class FacialFeature extends MovieClip
	{
		public var featureNameTextfield:TextField;
		public var featureSlider:DefaultSlider;
		
		var featureCategory:String;
		
		public function get FeatureName():String
		{
			return featureNameTextfield.text;
		}
		
		public function set FeatureName(value:String)
		{
			featureNameTextfield.text = value;
		}
		
		public function get FeatureCategory():String
		{
				return featureCategory;
		}
		
		public function set FeatureCategory(value:String)
		{
			featureCategory = value;
		}
		
		public function get FeatureValue():Number
		{
			return (featureSlider.position - featureSlider.minimum) / (featureSlider.maximum - featureSlider.minimum);
		}
		
		public function set FeatureValue(value:Number)
		{
			featureSlider.position = value * (featureSlider.maximum - featureSlider.minimum) + featureSlider.minimum;
		}
		
		
		public function FacialFeature()
		{
			FeatureName = "";
			featureSlider.liveDragging = true;
			featureSlider.addEventListener(SliderEvent.VALUE_CHANGE, SliderValueChanged);
		}
		
		public function SetData(data:Object):void 
		{
			if (data != null)
			{
				featureSlider.visible = true;
				
				if ("featureName" in data)
					FeatureName = data.featureName || "";
				else
					FeatureName = "";
					
				if ("featureCategory" in data)
					FeatureCategory = data.featureCategory || "";
				else
					FeatureCategory = "";
					
				if ("featureValue" in data)
					FeatureValue = data.featureValue || 0;
				else
					FeatureValue = 0;
			}
			else
			{
				featureSlider.visible = false;
				FeatureName = "";
				FeatureValue = 0;
			}
        }
		
		function SliderValueChanged(e:SliderEvent)
		{
			if (ExternalInterface.available) ExternalInterface.call("SliderValueChanged", FeatureName, FeatureCategory, FeatureValue);
		}
	}
}