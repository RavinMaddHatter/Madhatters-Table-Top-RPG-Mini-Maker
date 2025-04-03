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
var skeleton
var label

func set_lang():
	lable.text = tr(label)
	upload_button.text=tr("uploadOBJ")
	remove_button.text=tr("removeOBJ")
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
	label=text
	set_lang()
	
func set_anchor_point(anchor:BoneAttachment3D):
	anchor_point = anchor

func _upload_pressed():
	file_dialog.show()
func load_mesh(loaded_mesh):
	if loaded_mesh:
		x_pos_slider.value = loaded_mesh.position.x
		y_pos_slider.value = loaded_mesh.position.y
		z_pos_slider.value = loaded_mesh.position.z
		x_rot_slider.value = loaded_mesh.rotation.x
		y_rot_slider.value = loaded_mesh.rotation.y
		z_rot_slider.value = loaded_mesh.rotation.z
		var aabb = loaded_mesh.mesh.get_aabb()
		maxsize = max(aabb.size.x,aabb.size.y,aabb.size.z) - min(aabb.size.x,aabb.size.y,aabb.size.z)
		scale_slider.value = loaded_mesh.scale.x*maxsize
		mesh_object=MeshInstance3D.new()
		mesh_object.mesh=loaded_mesh.mesh
		mesh_object.position=loaded_mesh.position
		mesh_object.rotation=loaded_mesh.rotation
		mesh_object.name = lable.text
		anchor_point.add_child(mesh_object)
		slider_vbox.show()
		remove_button.show()
		upload_button.hide()
		_change_pose(0)

func _on_file_dialog_file_selected(file_path: String) -> void:
	slider_vbox.show()
	remove_button.show()
	upload_button.hide()
	var mesh = ObjParse.load_obj(file_path)
	mesh_object = MeshInstance3D.new()
	mesh_object.name = lable.text
	var aabb = mesh.get_aabb()
	maxsize = max(aabb.size.x,aabb.size.y,aabb.size.z) - min(aabb.size.x,aabb.size.y,aabb.size.z)
	mesh_object.mesh=mesh
	anchor_point.add_child(mesh_object)
	_change_pose(0)
	
func _remove_pressed():
	slider_vbox.hide()
	remove_button.hide()
	upload_button.show()
	if mesh_object:
		mesh_object.queue_free()

func _change_pose(_value):
	if mesh_object:
		mesh_object.position.x=x_pos_slider.value
		mesh_object.position.y=y_pos_slider.value
		mesh_object.position.z=z_pos_slider.value
		mesh_object.rotation.x=x_rot_slider.value
		mesh_object.rotation.y=y_rot_slider.value
		mesh_object.rotation.z=z_rot_slider.value
		mesh_object.scale=Vector3(scale_slider.value/maxsize, scale_slider.value/maxsize, scale_slider.value/maxsize)
