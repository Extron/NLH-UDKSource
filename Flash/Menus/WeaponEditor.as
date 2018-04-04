package 
{
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import scaleform.gfx.InteractiveObjectEx;
	import scaleform.gfx.MouseEventEx;
	import flash.text.TextField;

	public class WeaponEditor extends MovieClip
	{
		public var cursor:MenuCursor;
		public var saveButton:DefaultButton;
		public var cancelButton:DefaultButton;
		public var partTooltip:PartTooltip;
		public var energyBar:EnergyBar;
		public var weaponAttributes:WeaponAttributes;
		
		public var addMuzzleButton:SmallButton;
		public var addSideButton:SmallButton;
		public var addUnderButton:SmallButton;
		public var addOpticsButton:SmallButton;
		public var addStockButton:SmallButton;

		public var weaponNameTextfield:TextField;
		
		public function WeaponEditor()
		{
			scaleform.gfx.Extensions.enabled = true;
			
			addEventListener(Event.ADDED_TO_STAGE, AddedToStage);
			
			cursor.mouseChildren = false;
			cursor.mouseEnabled = false;
			InteractiveObjectEx.setTopmostLevel(cursor, true);
			InteractiveObjectEx.setHitTestDisable(cursor, true);
			
			saveButton.enabled = false;

			partTooltip.visible = false;
		}


		public function DropdownIndexChanged(obj:DropDownDisplay)
		{
			ExternalInterface.call("OnDropdownIndexChanged", obj.labelTextfield.text, obj.valueList.selectedIndex);
		}
		
		public function CloseMenu()
		{
			gotoAndPlay("Close");
		}
		
		public function AddAttribute(label:String, value:String)
		{
			weaponAttributes.AddAttribute(label, value);
		}
		
		public function AddDropDown(label:String, list:Array, index:Number)
		{
			weaponAttributes.AddDropDown(label, list, index);
		}
		
		public function SetEnergyReserve(energy:Number, maxEnergy:Number)
		{
			if (maxEnergy > 0)
			{
				energyBar.SetEnergy(energy, maxEnergy);
				energyBar.visible = true;
			}
			else
			{
				energyBar.visible = false;
			}
		}
		
		public function SetWeaponName(name:String)
		{
			weaponNameTextfield.text = name;
		}
		
		function AddedToStage(e:Event) 
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, MouseMoved, false, 0, true );
			stage.addEventListener(MouseEvent.CLICK, MouseClicked, false, 0, true );
			stage.addEventListener(MouseEvent.MOUSE_DOWN, MouseDown, false, 0, true );
			stage.addEventListener(MouseEvent.MOUSE_UP, MouseUp, false, 0, true );
		}
		
		function MouseMoved(e:MouseEvent) 
		{
			cursor.x = e.stageX;
			cursor.y = e.stageY;
			
			partTooltip.x = cursor.x
			partTooltip.y = cursor.y;
			
			ExternalInterface.call("OnMouseMove");
		}
		
		function MouseClicked(e:MouseEvent):void
		{
			if (e is MouseEventEx)
			{
				var ext = e as MouseEventEx;
		
				if (ext.buttonIdx == MouseEventEx.LEFT_BUTTON)
					ExternalInterface.call("OnMouseClick");
			}
		}
		
		function MouseDown(e:MouseEvent):void
		{
			if (e is MouseEventEx)
			{
				var ext = e as MouseEventEx;
		
				if (ext.buttonIdx == MouseEventEx.LEFT_BUTTON)
					ExternalInterface.call("OnMouseDown");
				else if (ext.buttonIdx == MouseEventEx.RIGHT_BUTTON)
					ExternalInterface.call("OnRightMouseDown");
			}
		}
		
		function MouseUp(e:MouseEvent):void
		{
			if (e is MouseEventEx)
			{
				var ext = e as MouseEventEx;
		
				if (ext.buttonIdx == MouseEventEx.LEFT_BUTTON)
					ExternalInterface.call("OnMouseUp");
				else if (ext.buttonIdx == MouseEventEx.RIGHT_BUTTON)
					ExternalInterface.call("OnRightMouseUp");
			}
		}
	}

}