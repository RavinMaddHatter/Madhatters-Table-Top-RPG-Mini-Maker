extends Control
signal change_equipment (values:Dictionary)
var slot
var cur_equipment = "None"
func add_entry(entry):
	$OptionButton.add_item(entry)

func set_slot(slot_name):
	$Label.text=slot_name
	slot=slot_name
func _on_option_button_item_selected(index: int) -> void:
	var data = {}
	data["slot"] = slot
	cur_equipment = $OptionButton.get_item_text(index)
	data["item_name"] = cur_equipment
	change_equipment.emit(data)
