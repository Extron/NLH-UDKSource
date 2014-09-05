package 
{
	import flash.events.Event;
	
	public class ComponentListEvent extends Event
	{
		public static const EQUIP_COMPONENT = "equipComponent";
		public static const PURCHASE_COMPONENT = "purchaseComponent";
		public static const CANCEL = "cancelComponent";
		
		public var selectedComponent:int;
		
		public function ComponentListEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}