package  {
	
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	
	public class WeaponLockerUI extends MovieClip {
		
		public var title:s_title_label;
		public var details:s_details;
		public var accept_button:DefaultButton;
		public var cancel_button:DefaultButton;
		public var add_muzzle_button:SmallButton;
		public var add_side_button:SmallButton;
		public var add_under_button:SmallButton;
		public var add_optics_button:SmallButton;
		public var add_stock_button:SmallButton;
		public var cursor:mouse_cursor;
		public var stat_tooltip:s_stat_tooltip;
		public var part_tooltip:s_part_tooltip;
		public var background:s_background;
		
		public function WeaponLockerUI() {
			// constructor code
		}
		
		public function DropdownIndexChanged(obj:s_value_ddl)
		{
			ExternalInterface.call("OnDropdownIndexChanged", obj.name_label.textField.text, obj.value_list.selectedIndex);
		}
	}
	
}
