package 
{
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import scaleform.clik.data.DataProvider;
	import flash.events.Event;
	import flash.text.TextField;
	import scaleform.clik.events.ListEvent;

	public class FacialFeaturesDetails extends InformationBoxDetails
	{
		public var generalTabButton:TabButton;
		public var foreheadTabButton:TabButton;
		public var eyesTabButton:TabButton;
		public var eyebrowsTabButton:TabButton;
		public var earsTabButton:TabButton;
		public var noseTabButton:TabButton;
		public var mouthTabButton:TabButton;
		public var cheekTabButton:TabButton;
		public var chinTabButton:TabButton;
		public var maleRadioButton:DefaultRadioButton;
		public var femaleRadioButton:DefaultRadioButton;
		public var hairColorPicker:ColorPickerPreview;
		public var eyeColorPicker:ColorPickerPreview;
		public var skinColorPicker:ColorPickerPreview;
		public var raceSlider:RaceSlider;
		public var hairDropdown:DefaultDropdownMenu;
		public var hairStyleLabel:TextField;
		
		var displayedFeatures:Array;
		
		var foreheadFeatures:Array;
		var eyeFeatures:Array;
		var eyebrowFeatures:Array;
		var earFeatures:Array;
		var noseFeatures:Array;
		var mouthFeatures:Array;
		var cheekFeatures:Array;
		var chinFeatures:Array;
		
		public function FacialFeaturesDetails()
		{
			displayedFeatures = new Array();
			foreheadFeatures = new Array();
			eyeFeatures = new Array();
			eyebrowFeatures = new Array();
			earFeatures = new Array();
			noseFeatures = new Array();
			mouthFeatures = new Array();
			cheekFeatures = new Array();
			chinFeatures = new Array();
			
			eyeColorPicker.addEventListener(ColorPickerEvent.COLOR_CHANGED, EyeColorChanged);
			hairColorPicker.addEventListener(ColorPickerEvent.COLOR_CHANGED, HairColorChanged);
			skinColorPicker.addEventListener(ColorPickerEvent.COLOR_CHANGED, SkinColorChanged);
			raceSlider.slider.addEventListener(BarycentricSliderEvent.SLIDER_MOVED, RaceChanged);
			maleRadioButton.addEventListener(Event.SELECT, GenderChanged);
			femaleRadioButton.addEventListener(Event.SELECT, GenderChanged);
			hairDropdown.addEventListener(ListEvent.INDEX_CHANGE, HairChanged);
		}
		
		public override function SetData(data:Object):void
		{
			if ("foreheadFeatures" in data) foreheadFeatures = data.foreheadFeatures;
			if ("eyesFeatures" in data) eyeFeatures = data.eyesFeatures;
			if ("eyebrowsFeatures" in data) eyebrowFeatures = data.eyebrowsFeatures;
			if ("earsFeatures" in data) earFeatures = data.earsFeatures;
			if ("noseFeatures" in data) noseFeatures = data.noseFeatures;
			if ("mouthFeatures" in data) mouthFeatures = data.mouthFeatures;
			if ("cheeksFeatures" in data) cheekFeatures = data.cheeksFeatures;
			if ("chinFeatures" in data) chinFeatures = data.chinFeatures;
			if ("hairStyles" in data) hairDropdown.dataProvider = new DataProvider(data.hairStyles);
			if ("currentHairStyle" in data) hairDropdown.selectedIndex = data.currentHairStyle;
			
			SetTabContents();
		}
		
		protected override function SetTabContents():void
		{
			ClearList();
			
			maleRadioButton.visible = false;
			femaleRadioButton.visible = false;
			hairColorPicker.visible = false;
			eyeColorPicker.visible = false;
			skinColorPicker.visible = false;
			raceSlider.visible = false;
			hairDropdown.visible = false;
			hairStyleLabel.visible = false;
			
			switch (tabButtons[selectedTab].label)
			{
			case "General":
				maleRadioButton.visible = true;
				femaleRadioButton.visible = true;
				hairColorPicker.visible = true;
				eyeColorPicker.visible = true;
				skinColorPicker.visible = true;
				raceSlider.visible = true;
				hairDropdown.visible = true;
				hairStyleLabel.visible = true;
				break;
				
			case "Forehead":
				BuildList(foreheadFeatures);
				break;
				
			case "Eyes":
				BuildList(eyeFeatures);
				break;
				
			case "Eyebrows":
				BuildList(eyebrowFeatures);
				break;
				
			case "Ears":
				BuildList(earFeatures);
				break;
				
			case "Nose":
				BuildList(noseFeatures);
				break;
				
			case "Mouth":
				BuildList(mouthFeatures);
				break;
				
			case "Cheeks":
				BuildList(cheekFeatures);
				break;
				
			case "Chin":
				BuildList(chinFeatures);
				break;
			}
		}
		
		function BuildList(featuresList:Array)
		{
			for (var i = 0; i < featuresList.length; i++)
			{
				var feature:FacialFeature = new FacialFeature();
				
				feature.SetData(featuresList[i]);
				
				feature.width = 240;
				feature.height = 20;
				feature.x = 128;
				feature.y = i * feature.height;
				
				displayedFeatures.push(feature);
				
				addChild(feature);
			}
		}
		
		function ClearList()
		{
			for (var i = 0; i < displayedFeatures.length; i++)
				removeChild(displayedFeatures[i]);
			
			while (displayedFeatures.length > 0)
				displayedFeatures.pop();
		}
		
		function EyeColorChanged(e:ColorPickerEvent)
		{
			if (ExternalInterface.available) ExternalInterface.call("ColorChanged", "Eyes", (e.Color >> 16) & 0xFF, (e.Color >> 8) & 0xFF, e.Color & 0xFF);
		}
		
		function HairColorChanged(e:ColorPickerEvent)
		{
			if (ExternalInterface.available) ExternalInterface.call("ColorChanged", "Hair", (e.Color >> 16) & 0xFF, (e.Color >> 8) & 0xFF, e.Color & 0xFF);
		}
		
		function SkinColorChanged(e:ColorPickerEvent)
		{
			if (ExternalInterface.available) ExternalInterface.call("ColorChanged", "Skin", (e.Color >> 16) & 0xFF, (e.Color >> 8) & 0xFF, e.Color & 0xFF);
		}
		
		function RaceChanged(e:BarycentricSliderEvent)
		{
			if (ExternalInterface.available) ExternalInterface.call("BarycentricSliderValueChanged", "Race", e.coordinates.x, e.coordinates.y, e.coordinates.z);
		}
		
		function GenderChanged(e:Event)
		{
			if (e.target == maleRadioButton)
			{
				if (ExternalInterface.available) ExternalInterface.call("RadioButtonSelected", "Male");
			}
			else if (e.target == femaleRadioButton)
			{
				if (ExternalInterface.available) ExternalInterface.call("RadioButtonSelected", "Female");
			}
		}
		
		function HairChanged(e:ListEvent)
		{
			if (ExternalInterface.available) ExternalInterface.call("DropdownSelectionChanged", "Hair", e.index);
		}
	}
}