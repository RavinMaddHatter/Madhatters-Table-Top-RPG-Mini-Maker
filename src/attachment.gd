extends VBoxContainer
var anchor_point:BoneAttachment3D
@export var lable:Label
@export var upload_button:Button
@export var remove_button:Button
@export var x_pos_slider:HSlider
@export var y_pos_slider:HSlider
@export var z_pos_slider:HSlider
@export var x_rot_slider:HSlider
@export var y_rot_slider:HSlider
@export var z_rot_slider:HSlider
@export var scale_slider:HSlider
@export var slider_vbox:VBoxContainer
@export var file_dialog:FileDialog
var mesh_object:MeshInstance3D
var maxsize:float

func _ready() -> void:
	file_dialog.current_dir = "/"
	file_dialog.use_native_dialog=true
	file_dialog.file_mode=FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.access=FileDialog.ACCESS_FILESYSTEM
	x_pos_slider.value_changed.connect(_change_pose)
	y_pos_slider.value_changed.connect(_change_pose)
	z_pos_slider.value_changed.connect(_change_pose)
	x_rot_slider.value_changed.connect(_change_pose)
	y_rot_slider.value_changed.connect(_change_pose)
	z_rot_slider.value_changed.connect(_change_pose)
	scale_slider.value_changed.connect(_change_pose)
func set_label(text):
	lable.text = text
	
func set_anchor_point(anchor:BoneAttachment3D):
	anchor_point = anchor

func _upload_pressed():
	file_dialog.show()
	slider_vbox.show()
	remove_button.show()
	upload_button.hide()
	var file_path = $FileDialog.current_file
	var mesh = ObjParse.load_obj(file_path)
	mesh_object = MeshInstance3D.new()
	var aabb = mesh.get_aabb()
	maxsize = max(aabb.size.x,aabb.size.y,aabb.size.z) - min(aabb.size.x,aabb.size.y,aabb.size.z)
	mesh_object.mesh=mesh
	anchor_point.add_child(mesh_object)

func _remove_pressed():
	slider_vbox.hide()
	remove_button.hide()
	upload_button.show()
	mesh_object.queue_free()

func _change_pose(_value):
	mesh_object.position.x=x_pos_slider.value
	mesh_object.position.y=y_pos_slider.value
	mesh_object.position.z=z_pos_slider.value
	mesh_object.rotation.x=x_rot_slider.value
	mesh_object.rotation.y=y_rot_slider.value
	mesh_object.rotation.z=z_rot_slider.value
	mesh_object.scale=Vector3(scale_slider.value/maxsize, scale_slider.value/maxsize, scale_slider.value/maxsize)
