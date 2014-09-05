package
{
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	
	public class CharacterView extends MovieClip
	{
		public var cursor:MenuCursor;
		public var titleLabel:TitleLabel;
		public var saveButton:DefaultButton;
		public var cancelButton:DefaultButton;
		public var popupWindow:DefaultWindow;
		public var xpBar:XPBar;
		public var componentList:ComponentList;
		
		public function CharacterView() 
		{
		}
		
		public function OpenComponentList(components:Array, selectedComponent:int)
		{
			gotoAndPlay("openComponentList");
			
			componentList.FillList(components, selectedComponent);
			componentList.addEventListener(ComponentListEvent.EQUIP_COMPONENT, EquipComponent);
			componentList.addEventListener(ComponentListEvent.PURCHASE_COMPONENT, PurchaseComponent);
			componentList.addEventListener(ComponentListEvent.CANCEL, CancelComponent);
		}
		
		function EquipComponent(e:ComponentListEvent)
		{
			gotoAndPlay("closeComponentList");
			if (ExternalInterface.available) ExternalInterface.call("EquipComponentSelection", e.selectedComponent);
		}
		
		function PurchaseComponent(e:ComponentListEvent)
		{
			if (ExternalInterface.available) ExternalInterface.call("PurchaseComponentSelection", e.selectedComponent);
		}
		
		function CancelComponent(e:ComponentListEvent)
		{
			gotoAndPlay("closeComponentList");
			if (ExternalInterface.available) ExternalInterface.call("CancelComponentSelection");
		}
	}
}
