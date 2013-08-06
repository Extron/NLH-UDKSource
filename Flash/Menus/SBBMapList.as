package  {
	
	import flash.display.MovieClip;
	import flash.ui.MouseCursor;
	import fl.containers.UILoader;
	
	public class SBBMapList extends MovieClip {
		
		public var itemList:MapList;
		public var cursor:MenuCursor;
		public var acceptButton:DefaultButton;
		public var cancelButton:DefaultButton;
		public var mapImage:MapImage;
		public var title:TitleLabel;
		public var description:DescriptionLabel;
		public var background:MapViewerBackground;
		public var tempTitle:String = "";
		public var tempDesc:String = "";
		public var tempImgSrc:String = "";

		public function SBBList() {
			// constructor code
		}
	}
	
}
