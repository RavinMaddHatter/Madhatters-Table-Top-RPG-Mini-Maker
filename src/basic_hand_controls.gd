extends MarginContainer
@export var left_fist = HSlider
@export var right_fist = HSlider
var skeleton : Skeleton3D
signal position_macro_set
func left_hand(value):
	const leftClosed={	"LeftIndexProximal":Vector3(5,48,50),
						"LeftIndexIntermediate":Vector3(33, 68, 50),
						"LeftIndexDistal":Vector3(-5,56,60),
						"LeftMiddleProximal":Vector3(35,45,30),
						"LeftMiddleIntermediate":Vector3(20, 68, 50),
						"LeftMiddleDistal":Vector3(20,80,70),
						"LeftRingProximal":Vector3(45,30,20),
						"LeftRingIntermediate":Vector3(50, 75, 57),
						"LeftRingDistal":Vector3(20,80,70),
						"LeftLittleProximal":Vector3(30,25,20),
						"LeftLittleIntermediate":Vector3(68, 68, 50),
						"LeftLittleDistal":Vector3(28,80,70)}
	const start_pose=Vector3(0,0,0)
	for key in leftClosed.keys():
		var bone_id = skeleton.find_bone(key)
		var bone_rotation= Quaternion.from_euler(start_pose.lerp(leftClosed[key],value)*TAU/360)
		skeleton.set_bone_pose_rotation(bone_id,bone_rotation)
	emit_signal("position_macro_set")
func left_thumb_close(value):
	const thumb_start ={"LeftThumbMetacarpal":Vector3(-35.5,89.9,0),
						"LeftThumbDistal":Vector3(0,0,0),
						"LeftThumbProximal":Vector3(0,0,0)}
	const thumb_fist = {"LeftThumbMetacarpal":Vector3(-35.5,89.9,0),
						"LeftThumbDistal":Vector3(0,60,45),
						"LeftThumbProximal":Vector3(0,50,0)}
	for key in thumb_fist.keys():
		var bone_id = skeleton.find_bone(key)
		var bone_rotation= Quaternion.from_euler(thumb_start[key].lerp(thumb_fist[key],value)*TAU/360)
		skeleton.set_bone_pose_rotation(bone_id,bone_rotation)
	emit_signal("position_macro_set")
func right_thumb_close(value):
	const thumb_start ={"RightThumbMetacarpal":Vector3(-35.5,-89.9,0),
						"RightThumbDistal":Vector3(0,0,0),
						"RightThumbProximal":Vector3(0,0,0)}
	const thumb_fist = {"RightThumbMetacarpal":Vector3(-35,-90,0),
						"RightThumbDistal":Vector3(0,-60,45),
						"RightThumbProximal":Vector3(0,-60,0)}
	for key in thumb_fist.keys():
		var bone_id = skeleton.find_bone(key)
		var bone_rotation= Quaternion.from_euler(thumb_start[key].lerp(thumb_fist[key],value)*TAU/360)
		skeleton.set_bone_pose_rotation(bone_id,bone_rotation)
	emit_signal("position_macro_set")
func right_hand(value):
	const rightClosed={	"RightIndexProximal":Vector3(-5,-48,-50),
						"RightIndexIntermediate":Vector3(55, -45, -45),
						"RightIndexDistal":Vector3(0,-45,-45),
						"RightMiddleProximal":Vector3(30,-45,-45),
						"RightMiddleIntermediate":Vector3(40, -45, -45),
						"RightMiddleDistal":Vector3(40,-45,-45),
						"RightRingProximal":Vector3(40,-45,-45),
						"RightRingIntermediate":Vector3(50, -45, -45),
						"RightRingDistal":Vector3(40,-45,-45),
						"RightLittleProximal":Vector3(50,-45,-45),
						"RightLittleIntermediate":Vector3(40, -45, -45),
						"RightLittleDistal":Vector3(40,-45,-45)}
	const start_pose=Vector3(0,0,0)
	for key in rightClosed.keys():
		var bone_id = skeleton.find_bone(key)
		var bone_rotation= Quaternion.from_euler(start_pose.lerp(rightClosed[key],value)*TAU/360)
		skeleton.set_bone_pose_rotation(bone_id,bone_rotation)
	#emit_signal("position_macro_set")
func bend_right_knee(value):
	const knee_default =Vector3(0,180,0)
	const knee_bent =Vector3(150,190,-3)
	var bone_id = skeleton.find_bone("RightLowerLeg")
	var bone_rotation= Quaternion.from_euler(knee_default.lerp(knee_bent,value)*TAU/360)
	skeleton.set_bone_pose_rotation(bone_id,bone_rotation)
	emit_signal("position_macro_set")

func bend_left_knee(value):
	const knee_default =Vector3(0,180,0)
	const knee_bent =Vector3(150,170,3)
	var bone_rotation= Quaternion.from_euler(knee_default.lerp(knee_bent,value)*TAU/360)
	var bone_id = skeleton.find_bone("LeftLowerLeg")
	skeleton.set_bone_pose_rotation(bone_id,bone_rotation)
	emit_signal("position_macro_set")

func spread_right_leg(value):
	var bone_id = skeleton.find_bone("RightUpperLeg")
	var min_pos = skeleton.get_bone_pose_rotation(bone_id).get_euler()
	var max_pos = skeleton.get_bone_pose_rotation(bone_id).get_euler()
	min_pos.z=190*TAU/360
	max_pos.z=56*TAU/360
	var bone_rotation= Quaternion.from_euler(min_pos.lerp(max_pos,value))
	skeleton.set_bone_pose_rotation(bone_id,bone_rotation)
	emit_signal("position_macro_set")

func spread_left_leg(value):
	var bone_id = skeleton.find_bone("LeftUpperLeg")
	var min_pos = skeleton.get_bone_pose_rotation(bone_id).get_euler()
	var max_pos = skeleton.get_bone_pose_rotation(bone_id).get_euler()
	min_pos.z=170*TAU/360
	max_pos.z=300*TAU/360
	var bone_rotation= Quaternion.from_euler(min_pos.lerp(max_pos,value))
	skeleton.set_bone_pose_rotation(bone_id,bone_rotation)
	emit_signal("position_macro_set")

func kick_right_leg(value):
	var bone_id = skeleton.find_bone("RightUpperLeg")
	var min_pos = skeleton.get_bone_pose_rotation(bone_id).get_euler()
	var max_pos = skeleton.get_bone_pose_rotation(bone_id).get_euler()
	min_pos.x=80*TAU/360
	max_pos.x=-125*TAU/360
	var bone_rotation= Quaternion.from_euler(min_pos.lerp(max_pos,value))
	skeleton.set_bone_pose_rotation(bone_id,bone_rotation)
	emit_signal("position_macro_set")

func kick_left_leg(value):
	var bone_id = skeleton.find_bone("LeftUpperLeg")
	var min_pos = skeleton.get_bone_pose_rotation(bone_id).get_euler()
	var max_pos = skeleton.get_bone_pose_rotation(bone_id).get_euler()
	min_pos.x=80*TAU/360
	max_pos.x=-125*TAU/360
	var bone_rotation= Quaternion.from_euler(min_pos.lerp(max_pos,value))
	skeleton.set_bone_pose_rotation(bone_id,bone_rotation)
	emit_signal("position_macro_set")

func twist_right_leg(value):
	var bone_id = skeleton.find_bone("RightUpperLeg")
	var min_pos = skeleton.get_bone_pose_rotation(bone_id).get_euler()
	var max_pos = skeleton.get_bone_pose_rotation(bone_id).get_euler()
	min_pos.y=45*TAU/360
	max_pos.y=-45*TAU/360
	var bone_rotation= Quaternion.from_euler(min_pos.lerp(max_pos,value))
	skeleton.set_bone_pose_rotation(bone_id,bone_rotation)
	emit_signal("position_macro_set")
func twist_left_leg(value):
	var bone_id = skeleton.find_bone("LeftUpperLeg")
	var min_pos = skeleton.get_bone_pose_rotation(bone_id).get_euler()
	var max_pos = skeleton.get_bone_pose_rotation(bone_id).get_euler()
	min_pos.y=-45*TAU/360
	max_pos.y=45*TAU/360
	var bone_rotation= Quaternion.from_euler(min_pos.lerp(max_pos,value))
	skeleton.set_bone_pose_rotation(bone_id,bone_rotation)
	emit_signal("position_macro_set")
func left_elbow(_value):
	emit_signal("position_macro_set")
func right_elbow(_value):
	const default = {"RightLowerArm":Vector3(0,90,0)}
	const straight = {"RightLowerArm":Vector3(0,90,0)}
	emit_signal("position_macro_set")
func curve_back(value):
	var straight ={"Chest":-25,
					"UpperChest":-25,
					"Neck":-25,
					"Head":-25}
	var curved = {	"Chest":22,
					"UpperChest":35,
					"Neck":30,
					"Head":22}
	for key in straight.keys():
		var bone_id = skeleton.find_bone(key)
		var min_pos = skeleton.get_bone_pose_rotation(bone_id).get_euler()
		var max_pos = skeleton.get_bone_pose_rotation(bone_id).get_euler()
		min_pos.x=straight[key]*TAU/360
		max_pos.x=curved[key]*TAU/360
		var bone_rotation= Quaternion.from_euler(min_pos.lerp(max_pos,value))
		skeleton.set_bone_pose_rotation(bone_id,bone_rotation)
	emit_signal("position_macro_set")
func back_twist(value):
	var left ={"Spine":-25,
					"Chest":-25,
					"UpperChest":-25}
	var right = {	"Spine":25,
					"Chest":25,
					"UpperChest":25}
	for key in left.keys():
		var bone_id = skeleton.find_bone(key)
		var min_pos = skeleton.get_bone_pose_rotation(bone_id).get_euler()
		var max_pos = skeleton.get_bone_pose_rotation(bone_id).get_euler()
		min_pos.y=left[key]*TAU/360
		max_pos.y=right[key]*TAU/360
		var bone_rotation= Quaternion.from_euler(min_pos.lerp(max_pos,value))
		skeleton.set_bone_pose_rotation(bone_id,bone_rotation)
	emit_signal("position_macro_set")
func back_lean(value):
	var left ={"Spine":-25,
					"Chest":-25,
					"UpperChest":-25}
	var right = {	"Spine":25,
					"Chest":25,
					"UpperChest":25}
	for key in left.keys():
		var bone_id = skeleton.find_bone(key)
		var min_pos = skeleton.get_bone_pose_rotation(bone_id).get_euler()
		var max_pos = skeleton.get_bone_pose_rotation(bone_id).get_euler()
		min_pos.z=left[key]*TAU/360
		max_pos.z=right[key]*TAU/360
		var bone_rotation= Quaternion.from_euler(min_pos.lerp(max_pos,value))
		skeleton.set_bone_pose_rotation(bone_id,bone_rotation)
	emit_signal("position_macro_set")
