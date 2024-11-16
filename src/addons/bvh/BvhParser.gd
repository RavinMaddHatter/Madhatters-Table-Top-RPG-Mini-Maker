

class_name BvhParser

class BvhJoint:
	var name : String
	var parent : BvhJoint
	var offset := Vector3(0,0,0)
	var children : Array[BvhJoint]
	var position := Vector3(0,0,0)
	var rotation := Quaternion()

class BvhJointT:
	var name : String
	var offset = Vector3(0,0,0)
	var channels : Array[String]
	var parent : BvhJointT
	var children : Array[BvhJointT]
	func _init(name, parent):
		self.name = name
		self.parent = parent
		self.offset = Vector3(0,0,0)
		self.channels = []
		self.children = []

	func add_child(child):
		self.children.append(child)

class channelKeyFrame:
	var channel : Array[float]

var joints = {}
var root = null
var keyframes : Array[channelKeyFrame]
var frames = 0
var fps = 0
var rootJointFrames : Array[BvhJoint] = []
	
class converterInfo:
	var joint : BvhJoint
	var iChannel : int
	func _init(joint : BvhJoint, iChannel : int):
		self.joint = joint
		self.iChannel = iChannel
		
func quat(r : Vector3) -> Quaternion:
	var q1 = Quaternion(Vector3(1,0,0), deg_to_rad(r.x))
	var q2 = Quaternion(Vector3(0,1,0), deg_to_rad(r.y))
	var q3 = Quaternion(Vector3(0,0,1), deg_to_rad(r.z))
	return q3 * q2 * q1 #best best
	return q3 * q1 * q2 #best
	return q2 * q3 * q1
	return q1 * q3 * q2 # no
	return q1 * q2 * q3 # no
	return q2 * q1 * q3 # no
	
func convertToJoint(parent : converterInfo, jt : BvhJointT, channel : Array[float]) -> converterInfo:
	var j = BvhJoint.new()
	j.name = jt.name
	j.offset = jt.offset
	j.parent = parent
	var iChannel = parent.iChannel
	var r = Vector3()
	for c in  jt.channels:
		match c:
			"Xposition": j.position.x = channel[iChannel]
			"Yposition": j.position.y = channel[iChannel]
			"Zposition": j.position.z = channel[iChannel]
			"Xrotation": r.x = channel[iChannel]
			"Yrotation": r.y = channel[iChannel]
			"Zrotation": r.z = channel[iChannel]
		iChannel += 1
	j.rotation = quat(r)
	for jtc in jt.children:
		var ci = convertToJoint(converterInfo.new(j, iChannel), jtc, channel)
		iChannel = ci.iChannel
		j.children.append(ci.joint)
	return converterInfo.new(j, iChannel)

func load(text : String):
	parse_string(text)
	for k in keyframes:
		var ci = convertToJoint(converterInfo.new(null, 0), root, k.channel)
		rootJointFrames.append(ci.joint)
func parse_string(text : String):
	var x = text.split("MOTION")
	var hierarchy = x[0]
	var motion = x[1]
	self._parse_hierarchy(hierarchy)
	self.parse_motion(motion)
	
	

func _parse_hierarchy(text : String):
	var lines = text.split("\n")
	var joint_stack = []
	for line in lines:
		if line == "":
			continue
		var wordsRe = RegEx.new()
		wordsRe.compile('[^\\s]+')
		var words2 : Array = wordsRe.search_all(line)
		var words = words2.map(func(x) : return x.get_string())
		var instruction = words[0].trim_suffix("\t").trim_prefix("\t")

		if instruction == "JOINT" or instruction == "ROOT":
			var parent = joint_stack[-1] if instruction == "JOINT" else null
			var joint = BvhJointT.new(words[1], parent)
			self.joints[joint.name] = joint
			if parent:
				parent.add_child(joint)
			joint_stack.append(joint)
			if instruction == "ROOT":
				self.root = joint
		elif instruction == "CHANNELS":
			for i in range(2, len(words)):
				joint_stack[-1].channels.append(words[i])
		elif instruction == "OFFSET":
			for i in range(1, len(words)):
				joint_stack[-1].offset[i - 1] = float(words[i])
		elif instruction == "End":
			var joint = BvhJointT.new(joint_stack[-1].name + "_end", joint_stack[-1])
			joint_stack[-1].add_child(joint)
			joint_stack.append(joint)
			self.joints[joint.name] = joint
		elif instruction == '}':
			joint_stack.pop_at(-1)


func parse_motion(text : String):
	var lines = text.split('\n')
	var framesRx = RegEx.new()
	framesRx.compile("Frames:[ ]*(?<n>[0-9]+)")
	var frameTimeRx = RegEx.new()
	frameTimeRx.compile("Frame Time:[ ]*(?<t>[0-9\\.]+)")
	var wordsRe = RegEx.new()
	wordsRe.compile('[^\\s]+')
	var frame = 0
	for line in lines:
		if line == '':
			continue
		var words2 : Array = wordsRe.search_all(line)
		var wordsArr = words2.map(func(x) : return x.get_string())
		var words = []
		for s in wordsArr:
			if s != "":
				words.append(s)
		if line.begins_with("Frame Time:"):
			var framesRxM = frameTimeRx.search(line)
			self.fps = round(1 / float(framesRxM.get_string("t")))
			continue
		if line.begins_with("Frames:"):
			var framesRxM = framesRx.search(line)
			self.frames = int(framesRxM.get_string("n"))
			continue
		if self.frames > 0:
			if len(self.keyframes) == 0:
				self.keyframes = []
				self.keyframes.resize(self.frames)
			self.keyframes[frame] = channelKeyFrame.new()
			self.keyframes[frame].channel.resize(len(words))
			for angle_index in range(len(words)):
				self.keyframes[frame].channel[angle_index] = float(words[angle_index])
			frame += 1
		
