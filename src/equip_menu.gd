extends Control
signal change_equipment (values:Dictionary)
var slot
var cur_equipment = "None"
func add_entry(entry):
	$OptionButton.add_item(entry)

func set_slot(slot_name):
	var slot_categories = ProjectSettings.get_setting("addons/humanizer/slots")
	var common_name= ""
	for type in slot_categories.keys():
		if slot_name in slot_categories[type]:
			common_name=slot_categories[type][slot_name]
	$Label.text=common_name
	slot=slot_name
func load_equipment(load_name):
	if load_name !="None":
		var data = {}
		data["slot"]=slot
		cur_equipment=load_name
		data["item_name"] = cur_equipment
		set_selected(cur_equipment)
		change_equipment.emit(data)
		
func set_selected(value):
	for index in range($OptionButton.item_count):
		if value == $OptionButton.get_item_text(index):
			$OptionButton.selected = index
func _on_option_button_item_selected(index: int) -> void:
	var data = {}
	data["slot"] = slot
	cur_equipment = $OptionButton.get_item_text(index)
	data["item_name"] = cur_equipment
	change_equipment.emit(data)
