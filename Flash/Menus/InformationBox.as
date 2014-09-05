package 
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flashx.textLayout.formats.Float;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.display.DisplayObject;
	import scaleform.clik.events.ButtonEvent;
	
	public class InformationBox extends MovieClip
	{
		public static const ClassLayout = "Class Layout";
		public static const WeaponLayout = "Weapon Layout";
		public static const ArmorLayout = "Armor Layout";
		public static const HeadLayout = "Head Layout";
		public static const LimbLayout = "Limb Layout";
		public static const StatLayout = "Stat Layout";

		public var title:TextField;
		public var subtitle:TextField;
		public var details:InformationBoxDetails;
		public var backButton:DefaultButton;
		public var activated:Boolean;
		public var titleText:String;
		public var subtitleText:String;
		public var cursor:MenuCursor;
		
		var prevOverObjects:Array;
		var prevOverObject:Object;
		
		public function InformationBox()
		{
			activated = false;
			
			addEventListener(Event.ADDED_TO_STAGE, OnAddedToStage);
			
			titleText = "";
			subtitleText = "";
			
			cursor.mouseChildren = false;
			cursor.mouseEnabled = false;
			
			prevOverObjects = [];
		}
		
		public function SetCursorLocation(x:Number, y:Number, mouseDown:Boolean)
		{
			cursor.x = x;
			cursor.y = y;
			
			var point = new Point(x, y);
			var objects:Array = stage.getObjectsUnderPoint(point);
			
			var i = 0;
			var object;
			var localPoint;

			if (objects.length < 0)
				return;

			var last = objects.length;
			
			do
			{
				last--;
				
				while (!(objects[last] is MovieClip) && objects[last].hasOwnProperty("parent"))
					objects[last] = objects[last].parent;
				
				object = objects[last];
			}
			while (object is MenuCursor && object != null)
			
			if (object is InformationBox || object is MenuCursor)
				return;
				
			if (object is MovieClip)
			{
				localPoint = (object as DisplayObject).globalToLocal(point);

				(object as MovieClip).dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE, true, false, localPoint.x, localPoint.y, null, false, false, false, mouseDown));
				
				if (prevOverObject != null && prevOverObject != object)
				{
					(prevOverObject as MovieClip).dispatchEvent(new MouseEvent(MouseEvent.ROLL_OUT, true, false, localPoint.x, localPoint.y));
					prevOverObject = null;
				}
				
				if (prevOverObject != object)
				{
					(object as MovieClip).dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER, true, false, localPoint.x, localPoint.y));
					prevOverObject = object;
				}
				
			}
		}
		
		public function ClickMouse()
		{
			var point = new Point(cursor.x, cursor.y);
			var objects:Array = stage.getObjectsUnderPoint(point);

			if (objects.length < 0)
				return;

			var last = objects.length;
			
			do
			{
				last--;
				
				while (!(objects[last] is MovieClip) && objects[last].hasOwnProperty("parent"))
					objects[last] = objects[last].parent;
				
				var object = objects[last];
			}
			while (object is MenuCursor && object != null)
			
			if (object is InformationBox || object is MenuCursor)
				return;
				
			
			if (object is MovieClip)
			{
				var localPoint = (object as DisplayObject).globalToLocal(point);
				(object as MovieClip).dispatchEvent(new MouseEvent(MouseEvent.CLICK, true, false, localPoint.x, localPoint.y));
			}
		}
		
		public function MouseDown()
		{
			var point = new Point(cursor.x, cursor.y);
			var objects:Array = stage.getObjectsUnderPoint(point);

			if (objects.length < 0)
				return;

			var last = objects.length;
			
			do
			{
				last--;
				
				while (!(objects[last] is MovieClip) && objects[last].hasOwnProperty("parent"))
					objects[last] = objects[last].parent;
				
				var object = objects[last];
			}
			while (object is MenuCursor && object != null)
			
			if (object is InformationBox || object is MenuCursor)
				return;
				
			
			if (object is MovieClip)
			{
				var localPoint = (object as DisplayObject).globalToLocal(point);
				(object as MovieClip).dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, localPoint.x, localPoint.y));
			}
		}
		
		public function MouseUp()
		{
			var point = new Point(cursor.x, cursor.y);
			var objects:Array = stage.getObjectsUnderPoint(point);

			if (objects.length < 0)
				return;

			var last = objects.length;
			
			do
			{
				last--;
				
				while (!(objects[last] is MovieClip) && objects[last].hasOwnProperty("parent"))
					objects[last] = objects[last].parent;
				
				var object = objects[last];
			}
			while (object is MenuCursor && object != null)
			
			if (object is InformationBox || object is MenuCursor)
				return;
				
			
			if (object is MovieClip)
			{
				var localPoint = (object as DisplayObject).globalToLocal(point);
				(object as MovieClip).dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, true, false, localPoint.x, localPoint.y));
			}
		}
		
		public function SetTitle(titleString:String):void
		{
			titleText = titleString;
			stage.invalidate();
		}
		
		public function SetSubtitle(subtitleString:String):void
		{
			subtitleText = subtitleString;
			stage.invalidate();
		}
		
		public function PopulateInformation(layout:String, data:Object):void
		{
			switch (layout)
			{
			case ClassLayout:
				details = new ClassDetails();
				break;
				
			case WeaponLayout:
				details = new WeaponDetails();
				break;
				
			case ArmorLayout:
				details = new ArmorDetails();
				break;
				
			case StatLayout:
				details = new StatDetails();
				break;
				
			case HeadLayout:
				details = new HeadDetails();
				break;
				
			case LimbLayout:
				details = new LimbDetails();
				break;
				
			default:
				details = null;
				return;
			}
			
			details.SetData(data);
			
			details.x = 208;
			details.y = 112;
			
			details.addEventListener("Details Closed", OnDetailsClosed);
			details.visible = false;
			
			addChild(details);
		}

		public function UpdateInformaiton(data:Object)
		{
			details.SetData(data);
		}
		
		public function Highlight()
		{
			gotoAndPlay("Highlight");
		}
		
		public function DeHighlight()
		{
			gotoAndPlay("DeHighlight");
		}
		
		public function Activate()
		{
			gotoAndPlay("Activating");
		}
		
		public function Deactivate()
		{
			if (details != null) 
				details.gotoAndPlay("Closing");
			else if (ExternalInterface.available)
				ExternalInterface.call("InfoBoxBack");
		}
		
		function RemoveDuplicates(a:Array)
		{
			a.sort();
			
			var i:Number = 0;
			
			while(i < a.length)
			{
				while(i < a.length+1 && a[i] == a[i+1])
					a.splice(i, 1);
					
				i++;
			}
		}
		
		
		function OnMouseMove(e:MouseEvent)
		{
			//SetCursorLocation(stage.mouseX, stage.mouseY);
			/*var point = new Point(e.stageX, e.stageY);
			var objects:Array = stage.getObjectsUnderPoint(point);
			
			var i = 0;
			var object;
			var localPoint;

			if (objects.length < 0)
				return;
			
			for (var i = 0; i < objects.length; i++)
			{
				while (!(objects[i] is MovieClip) && objects[i].hasOwnProperty("parent"))
					objects[i] = objects[i].parent;
				
				trace(i + " " + objects[i]);
			}*/
		}

		function OnMouseClick(e:MouseEvent)
		{
			//ClickMouse();
			if (ExternalInterface.available) ExternalInterface.call("OnMouseClick");
		}
		
		function OnBackButtonClicked(e:ButtonEvent)
		{
			Deactivate();
		}
		
		protected function OnAddedToStage(ev:Event):void 
		{
			stage.addEventListener(Event.RENDER, OnRenderStage);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, OnMouseMove, false, 0, true);
			stage.addEventListener(MouseEvent.CLICK, OnMouseClick, false, 0, true);
		}
		
		protected function OnRenderStage(ev:Event):void
		{
			title.text = titleText;
			subtitle.text = subtitleText;
		}
		
		function OnDetailsClosed(e:Event)
		{
			gotoAndPlay("Deactivating");
			
			removeChild(details);
			
			if (ExternalInterface.available) ExternalInterface.call("InfoBoxBack");
		}
		
		public function dispose():void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, OnAddedToStage);
			
			if (stage != null)
				stage.removeEventListener(Event.RENDER, OnRenderStage);
		}
	}
}