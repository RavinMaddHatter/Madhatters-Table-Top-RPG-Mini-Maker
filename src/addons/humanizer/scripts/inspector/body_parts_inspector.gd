@tool
class_name BodyPartsInspector
extends MarginContainer

static var visible_setting := false
var registry
var last_materials := {}
var asset_option_buttons := {}
var texture_option_buttons := {}
var config: HumanConfig

signal body_part_changed(bp: HumanizerEquipmentType)
signal body_slot_cleared(slot: String)
signal material_set(slot: String, texture: String)


func _ready() -> void:
	visibility_changed.connect(_set_visibility)
	build_grid()
	await get_tree().process_frame
	registry = HumanizerRegistry
	for slot in HumanizerGlobalConfig.config.body_part_slots:
		asset_option_buttons[slot] = get_node('%' + slot + 'OptionButton')
		texture_option_buttons[slot] = get_node('%' + slot + 'TextureOptionButton')
		
		asset_option_buttons[slot].clear()
		texture_option_buttons[slot].clear()
		
		var options = asset_option_buttons[slot] as OptionButton
		var materials = texture_option_buttons[slot] as OptionButton

		options.item_selected.connect(_item_selected.bind(slot))
		materials.item_selected.connect(_material_selected.bind(slot))

		options.add_item('None')
		for asset in registry.filter_equipment({slot=slot}):
			options.add_item(asset.resource_name)
			
	if config != null:
		fill_table(config)

func _set_visibility() -> void:
	visible_setting = visible

func build_grid() -> void:
	var grid = get_node('%GridContainer')
	for slot in HumanizerGlobalConfig.config.body_part_slots:
		var label = Label.new()
		label.text = slot
		grid.add_child(label)
		grid.add_child(VSeparator.new())
		label = Label.new()
		label.text = 'Asset'
		grid.add_child(label)
		var options = OptionButton.new()
		options.name = slot + 'OptionButton'
		grid.add_child(options)
		options.unique_name_in_owner = true
		options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(VSeparator.new())
		label = Label.new()
		label.text = 'Texture'
		grid.add_child(label)
		options = OptionButton.new()
		options.name = slot + 'TextureOptionButton'
		grid.add_child(options)
		options.unique_name_in_owner = true
		options.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for child in grid.get_children():
		child.owner = self

func fill_table(config: HumanConfig) -> void:
	for slot in HumanizerGlobalConfig.config.body_part_slots:
		var bp: HumanizerEquipment = config.get_equipment_in_slot(slot)
		if bp != null:
			var options = asset_option_buttons[slot] as OptionButton
			for option in options.item_count:
				if options.get_item_text(option) == bp.get_type().resource_name:
					options.selected = option
					_item_selected(option, slot)
					break
			
			for option in texture_option_buttons[slot].item_count:
				if texture_option_buttons[slot].get_item_text(option) == bp.texture_name:
					texture_option_buttons[slot].selected = option
			
func _item_selected(index: int, slot: String):
	var options = asset_option_buttons[slot]
	var texture_options = texture_option_buttons[slot]
	texture_options.clear()
	
	var name = options.get_item_text(options.get_selected_id())
	if name == 'None':
		body_slot_cleared.emit(slot)
		return
	
	texture_options.add_item("")
	for mat in registry.equipment[name].textures:
		texture_options.add_item(mat)
	
	if config == null or config.get_equipment_in_slot(slot) == null or not name in config.equipment:
		body_part_changed.emit(registry.equipment[name])
		
func _material_selected(idx: int, slot: String) -> void:
	material_set.emit(slot, (texture_option_buttons[slot] as OptionButton).get_item_text(idx))
