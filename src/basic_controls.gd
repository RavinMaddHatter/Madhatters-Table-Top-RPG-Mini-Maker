#the functions in this script were set up to make sensible poses using simple sliders
#These are not perfect, i am not properly locking the joints. It is simply using lerp
#to give the illusion of sensiblity. It constrains the poses a bit more than would be 
#natural. but i am not good with kinimatics. It is just hacks to make it work. 
extends MarginContainer
var skeleton : Skeleton3D
signal position_macro_set
@export var left_wrist_ud: HSlider
@export var left_wrist_io: HSlider
@export var left_wrist_tw: HSlider
@export var right_wrist_ud: HSlider
@export var right_wrist_io: HSlider
@export var right_wrist_tw: HSlider
@export var left_sholder_swing: HSlider
@export var left_sholder_lift: HSlider
@export var left_sholder_shrug: HSlider
@export var left_sholder_curl: HSlider
@export var right_sholder_swing: HSlider
@export var right_sholder_lift: HSlider
@export var right_sholder_shrug: HSlider
@export var right_sholder_curl: HSlider
@export var head_rotate: HSlider
@export var head_pitch: HSlider
@export var head_roll: HSlider
@export var right_hip_lift: HSlider
@export var right_hip_twist: HSlider
@export var right_hip_spread: HSlider
@export var left_hip_lift: HSlider
@export var left_hip_twist: HSlider
@export var left_hip_spread: HSlider
@export var back_twist: HSlider
@export var back_lean: HSlider
@export var back_curve: HSlider

func left_hand(value):
	#The following values were manually evaluated. The finger is a 1 DoF item so each finger has
	#an open and close position. unforunately the fingers are not alinged with sensible bend directions
	#in this skeleton.
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
	#this is emitted to set the detailed poses.
	emit_signal("position_macro_set")
func right_hand(value):
	#The following values were manually evaluated. The finger is a 1 DoF item so each finger has
	#an open and close position. unforunately the fingers are not alinged with sensible bend directions
	#in this skeleton.
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
	#this is emitted to set the detailed poses.
	emit_signal("position_macro_set")
func left_thumb_close(value):
	##The thum has more than 1 degree of freedom. however for simplicity, this is 
	#moving along 1 path. This will now work for eveyr aspect, but for now it is decent
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
	#this is emitted to set the detailed poses.
	emit_signal("position_macro_set")
func right_thumb_close(value):
	##The thum has more than 1 degree of freedom. however for simplicity, this is 
	#moving along 1 path. This will now work for eveyr aspect, but for now it is decent
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

func bend_right_knee(value):
	#The Knee is a single degree of freedom joint, the start and stop are locked and we simply lerp 
	const knee_default =Vector3(0,180,0)
	const knee_bent =Vector3(150,190,-3)
	var bone_id = skeleton.find_bone("RightLowerLeg")
	var bone_rotation= Quaternion.from_euler(knee_default.lerp(knee_bent,value)*TAU/360)
	skeleton.set_bone_pose_rotation(bone_id,bone_rotation)
	#this is emitted to set the detailed poses.
	emit_signal("position_macro_set")

func bend_left_knee(value):
	#The Knee is a single degree of freedom joint, the start and stop are locked and we simply lerp 
	const knee_default =Vector3(0,180,0)
	const knee_bent =Vector3(150,170,3)
	var bone_rotation= Quaternion.from_euler(knee_default.lerp(knee_bent,value)*TAU/360)
	var bone_id = skeleton.find_bone("LeftLowerLeg")
	skeleton.set_bone_pose_rotation(bone_id,bone_rotation)
	#this is emitted to set the detailed poses.
	emit_signal("position_macro_set")

func right_hip(_value):
	#the hip is a 3 DoF joint. To prevent unrecoverable changes, all transforms are 
	#applied in a consistent order.
	var bone_id = skeleton.find_bone("RightUpperLeg")
	var bone_rot = Vector3()
	bone_rot.x=lerp(80*TAU/360,-125*TAU/360,right_hip_lift.value)
	bone_rot.y=lerp(45*TAU/360,-45*TAU/360,right_hip_twist.value)
	bone_rot.z=lerp(190*TAU/360,56*TAU/360,right_hip_spread.value)
	skeleton.set_bone_pose_rotation(bone_id,Quaternion.from_euler( bone_rot))
	#this is emitted to set the detailed poses.
	emit_signal("position_macro_set")
func left_hip(_value):
	#the hip is a 3 DoF joint. To prevent unrecoverable changes, all transforms are 
	#applied in a consistent order.
	var bone_id = skeleton.find_bone("LeftUpperLeg")
	var bone_rot = Vector3()
	bone_rot.x=lerp(80*TAU/360,-125*TAU/360,left_hip_lift.value)
	bone_rot.y=lerp(-45*TAU/360,45*TAU/360,left_hip_twist.value)
	bone_rot.z=lerp(170*TAU/360,300*TAU/360,left_hip_spread.value)
	skeleton.set_bone_pose_rotation(bone_id,Quaternion.from_euler(bone_rot))
	#this is emitted to set the detailed poses.
	emit_signal("position_macro_set")

func left_elbow(value):
	#the elbow is a 1 DoF joint, simple lerp is applied
	const straight = Vector3(-20,-50,0)
	const bent = Vector3(80,-200,0)
	var bone_id = skeleton.find_bone("LeftLowerArm")
	var bone_rotation= Quaternion.from_euler(straight.lerp(bent,value)*TAU/360)
	skeleton.set_bone_pose_rotation(bone_id, bone_rotation)
	emit_signal("position_macro_set")
	
func right_elbow(value):
	#the elbow is a 1 DoF joint, simple lerp is applied
	const straight = Vector3(-20,50,0)
	const bent = Vector3(80,200,0)
	var bone_id = skeleton.find_bone("RightLowerArm")
	var bone_rotation= Quaternion.from_euler(straight.lerp(bent,value)*TAU/360)
	skeleton.set_bone_pose_rotation(bone_id,bone_rotation)
	
func left_wrist(_value):
	#the wrist is an incredibly complex joint. constraining movement broke my brain,
	#i gave up and just expose some reaonsbale limits 
	var bone_id = skeleton.find_bone("LeftHand")
	var left_wrist_pose=Vector3()
	left_wrist_pose.x=lerp(-71*TAU/360,137*TAU/360,left_wrist_ud.value)
	left_wrist_pose.y=lerp(20*TAU/360,140*TAU/360,left_wrist_io.value)
	left_wrist_pose.z=lerp(-90*TAU/360,60*TAU/360,left_wrist_tw.value)
	var bone_rotation = Quaternion.from_euler(left_wrist_pose)
	skeleton.set_bone_pose_rotation(bone_id,bone_rotation)
	emit_signal("position_macro_set")
func right_wrist(_value):
	#the wrist is an incredibly complex joint. constraining movement broke my brain,
	#i gave up and just expose some reaonsbale limits 
	var bone_id = skeleton.find_bone("RightHand")
	var right_wrist_pose=Vector3()
	right_wrist_pose.x=lerp(-71*TAU/360,137*TAU/360,right_wrist_ud.value)
	right_wrist_pose.y=lerp(-20*TAU/360,-140*TAU/360,right_wrist_io.value)
	right_wrist_pose.z=lerp(-90*TAU/360,60*TAU/360,right_wrist_tw.value)
	var bone_rotation = Quaternion.from_euler(right_wrist_pose)
	skeleton.set_bone_pose_rotation(bone_id,bone_rotation)
	emit_signal("position_macro_set")
func back(_value):
	#the back is a 3 dof joint set that move together. For that reason, all joints are 
	#computed in unison and moved directly. To prevent unrecoverable changes the order
	#is computed the same way each time.
	var chest_id = skeleton.find_bone("Chest")
	var upper_chest_id = skeleton.find_bone("UpperChest")
	var chest_rot=Vector3()
	var upper_chest_rot=Vector3()
	#cacluating twist
	chest_rot.y = lerp(-45*TAU/360,45*TAU/360,back_twist.value)
	upper_chest_rot.y = lerp(-45*TAU/360,45*TAU/360,back_twist.value)
	#calculating lean
	chest_rot.z = lerp(-25*TAU/360,25*TAU/360,back_lean.value)
	upper_chest_rot.z = lerp(-25*TAU/360,25*TAU/360,back_lean.value)
	#calculating curve
	chest_rot.x = lerp(-22*TAU/360,22*TAU/360,back_curve.value)
	upper_chest_rot.x = lerp(-35*TAU/360,35*TAU/360,back_curve.value)
	skeleton.set_bone_pose_rotation(chest_id,Quaternion.from_euler(chest_rot))
	skeleton.set_bone_pose_rotation(upper_chest_id,Quaternion.from_euler( upper_chest_rot))
	emit_signal("position_macro_set")


func left_sholder(_value):
	#This function is setup to make sensible repeatable poses. Euler angles can get really messy with application order
	var sholder_id = skeleton.find_bone("LeftShoulder")
	var sholderRotation = skeleton.get_bone_pose_rotation(sholder_id).get_euler()
	sholderRotation.x = lerp(-103*TAU/360,-25*TAU/360,left_sholder_shrug.value)
	sholderRotation.y = lerp(-134*TAU/360,-50*TAU/360,left_sholder_curl.value)
	sholderRotation.z=0
	skeleton.set_bone_pose_rotation(sholder_id,Quaternion.from_euler(sholderRotation))
	var arm_id = skeleton.find_bone("LeftUpperArm")
	var armRotation = skeleton.get_bone_pose_rotation(arm_id).get_euler()
	armRotation.x=lerp(-70*TAU/360,80*TAU/360,left_sholder_lift.value)
	armRotation.y=lerp( 90*TAU/360,270*TAU/360,left_sholder_swing.value)
	skeleton.set_bone_pose_rotation(arm_id,Quaternion.from_euler(armRotation))
func right_sholder(_value):
	#This function is setup to make sensible repeatable poses. Euler angles can get really messy with application order
	var sholder_id = skeleton.find_bone("RightShoulder")
	var sholderRotation = skeleton.get_bone_pose_rotation(sholder_id).get_euler()
	sholderRotation.x = lerp(-103*TAU/360,-25*TAU/360,right_sholder_shrug.value)
	sholderRotation.y = lerp(134*TAU/360,50*TAU/360,right_sholder_curl.value)
	sholderRotation.z=0
	skeleton.set_bone_pose_rotation(sholder_id,Quaternion.from_euler(sholderRotation))
	var arm_id = skeleton.find_bone("RightUpperArm")
	var armRotation = skeleton.get_bone_pose_rotation(arm_id).get_euler()
	armRotation.x=lerp(-70*TAU/360,80*TAU/360,right_sholder_lift.value)
	armRotation.y=lerp( 90*TAU/360,270*TAU/360,right_sholder_swing.value)
	skeleton.set_bone_pose_rotation(arm_id,Quaternion.from_euler(armRotation))
func head(_value):
	#the head possion is controled by a 2 3 dof joints. To make sure the head 
	#doesnt go into an unrecoverable position, the 3 movements are caculated in order.
	var neck_id = skeleton.find_bone("Neck")
	var neck_rot = skeleton.get_bone_pose_rotation(neck_id).get_euler()
	neck_rot.x = lerp(-30*TAU/360,35*TAU/360,head_pitch.value)
	neck_rot.y = lerp(-45*TAU/360,45*TAU/360,head_rotate.value)
	neck_rot.z=lerp( -20*TAU/360,20*TAU/360,head_roll.value)
	skeleton.set_bone_pose_rotation(neck_id,Quaternion.from_euler(neck_rot))
	var arm_id = skeleton.find_bone("Head")
	var armRotation = skeleton.get_bone_pose_rotation(arm_id).get_euler()
	armRotation.x=lerp(-30*TAU/360,35*TAU/360,head_pitch.value)
	armRotation.y=lerp( -45*TAU/360,45*TAU/360,head_rotate.value)
	armRotation.z=lerp( -30*TAU/360,30*TAU/360,head_roll.value)
	skeleton.set_bone_pose_rotation(arm_id,Quaternion.from_euler(armRotation))
