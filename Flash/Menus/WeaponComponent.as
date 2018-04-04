package 
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.external.ExternalInterface;
	import flash.display.Loader;
	import flash.display.Bitmap;
	import flash.net.URLRequest;
	import flash.events.Event;
	
	public class WeaponComponent extends MovieClip
	{
		public var componentCategory:TextField;
		public var componentName:TextField;
		
		var loader:Loader;
		var image:Bitmap;

		public function WeaponComponent()
		{
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, LoadComplete, false, 0 , true);
		}
		
		public function SetData(data:Object)
		{
			if (data.hasOwnProperty("category")) componentCategory.text = data.category;
			if (data.hasOwnProperty("name")) componentName.text = data.name;
			
			if (data.hasOwnProperty("imgSrc")) LoadImage(data.imgSrc);
		}
		
		function LoadImage(imgSrc:String)
		{
			var urlReq:URLRequest = new URLRequest(imgSrc);
			
			if (loader == null)
				loader = new Loader();
				
			loader.load(urlReq);
		}
		
		function ClearImage()
		{
			removeChild(image);
		}
		
		function LoadComplete(event:Event):void
		{
			image = Bitmap(loader.content);
			image.x = 384;
			image.y = 0;
			image.width = 128;
			image.height = 128;
			
			addChild(image);
		}
	}
}