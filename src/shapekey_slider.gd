extends VBoxContainer
class_name Shapekey_Slider_2

signal change_shapekeys (values:Dictionary)

var label_name : String
var shapekeys = [] #for lefts and rights
var changed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_lang()
	set_line_edit_from_slider_value()
	
func set_lang():
	$Label_Container/Label.text=d.ltr(label_name)
func reset():
	$Slider.value=0.0
	$Label_Container/Value_Edit.text="0.0"
	changed = false
func emit_shapekeys():
	var data = {}
	for shapekey_name in shapekeys:
		data[shapekey_name] = $Slider.value / 100
	change_shapekeys.emit(data)

func set_line_edit_from_slider_value():
	$Label_Container/Value_Edit.text = str($Slider.value)
	changed = true
	
func set_value(value:float):
	$Slider.value = value
	changed = true
func get_value():
	return $Slider.value

func slider_drag_ended(_value_changed):
	set_line_edit_from_slider_value()
	emit_shapekeys()

func slider_value_changed(_value):
	set_line_edit_from_slider_value()

func value_edit_text_submitted(new_text):
	if new_text.is_valid_float():
		var new_value = new_text.to_float()
		if new_value < $Slider.min_value:
			new_value = $Slider.min_value
		elif new_value > $Slider.max_value:
			new_value = $Slider.max_value
		$Slider.value = new_value
		emit_shapekeys()
	else:
		set_line_edit_from_slider_value()
