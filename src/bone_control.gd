extends MarginContainer
var skel:Skeleton3D
var humanizer:Live_Humanizer
var bone_id:int
@export var x_slider:HSlider
@export var y_slider:HSlider
@export var z_slider:HSlider
@export var title:Label
@export var x_text:LineEdit
@export var y_text:LineEdit
@export var z_text:LineEdit
var origin
var bone_name="None"
	
func setup(bone_handle:String,skeleton,id):
	bone_name = bone_handle
	set_lang()
	skel=skeleton
	bone_id=id
	set_sliders()
func set_lang():
	title.text=tr(bone_name)
	$VBoxContainer/Sliders/Labels/xLabel.text = tr("X") + " " + tr("rotation
")
	$VBoxContainer/Sliders/Labelsy/yLabel.text = tr("Y") + " " + tr("rotation
")
	$VBoxContainer/Sliders/Labels2/zLabel.text = tr("Z") + " " + tr("rotation
")
func set_sliders():
	skel=humanizer.get_skeleton_node()
	var pose = skel.get_bone_pose(bone_id)
	origin = pose.origin
	x_slider.value=pose.basis.get_euler().x
	y_slider.value=pose.basis.get_euler().y
	z_slider.value=pose.basis.get_euler().z
func load_value(values):
	x_slider.value = values["x"]
	y_slider.value = values["y"]
	z_slider.value = values["z"]
	set_bone_pose()
func set_bone_pose():
	var rot_vector = Vector3()
	rot_vector.x = x_slider.value
	rot_vector.y = y_slider.value
	rot_vector.z = z_slider.value
	var bone_rotation= Quaternion.from_euler(rot_vector)
	skel.reset_bone_pose(bone_id)
	skel.set_bone_pose_rotation(bone_id,bone_rotation)
func get_sliders():
	return {"x":x_slider.value,
			"y":y_slider.value,
			"z":z_slider.value}
func set_slider_value(values):
	x_slider.value=values.x
	y_slider.value=values.y
	z_slider.value=values.z

func _on_x_slider_value_changed(_value: float) -> void:
	x_text.text=str(x_slider.value*360/TAU).pad_decimals(1)
	set_bone_pose()


func _on_y_slider_value_changed(_value: float) -> void:
	y_text.text=str(y_slider.value*360/TAU).pad_decimals(1)
	set_bone_pose()


func _on_z_slider_value_changed(_value: float) -> void:
	z_text.text=str(z_slider.value*360/TAU).pad_decimals(1)
	set_bone_pose()


func _on_value_edit_text_submitted(new_text: String) -> void:
	if new_text.is_valid_float():
		x_slider.value=float(new_text)*TAU/360
	else:
		_on_x_slider_value_changed(0)
		

func _on_y_edit_value_text_submitted(new_text: String) -> void:
	if new_text.is_valid_float():
		y_slider.value=float(new_text)*TAU/360
	else:
		_on_y_slider_value_changed(0)


func _on_z_edit_value_text_submitted(new_text: String) -> void:
	if new_text.is_valid_float():
		z_slider.value=float(new_text)*TAU/360
	else:
		_on_z_slider_value_changed(0)
