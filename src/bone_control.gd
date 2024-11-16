extends MarginContainer
var skeleton:Skeleton3D
var bone_id:int
@export var x_slider:HSlider
@export var y_slider:HSlider
@export var z_slider:HSlider
@export var title:Label
func setup(name:String,skel,id):
	title.text=name
	skeleton=skel
	bone_id=id
	var pose = skeleton.get_bone_pose(id)
	x_slider.value=pose.basis.get_euler().x
	y_slider.value=pose.basis.get_euler().y
	z_slider.value=pose.basis.get_euler().z
	
func _ready():
	pass
func set_bone_pose():
	var pose = Transform3D()
	var x = Vector3()
	var y = Vector3()
	var z = Vector3()
	x.x=1
	y.y=1
	z.z=1
	pose=pose.rotated(y,y_slider.value)
	pose=pose.rotated(x,x_slider.value)
	pose=pose.rotated(z,y_slider.value)
	skeleton.set_bone_pose(bone_id,pose)
