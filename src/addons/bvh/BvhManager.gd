
class_name BvhManager

var _anims : Array[BvhAnim]
var _current_anim = -1

class BvhAnim:
	var _bvhTransformers : Array[BvhTransformer]
	var _fps : float
	var index = -1
	
	var frameCount : float:
		get:
#			print(len(_bvhTransformers))
			return len(_bvhTransformers)
	var fps : float:
		get:
			return _fps
			
	func _init(bvh : BvhParser):
		_fps = bvh.fps
		for f in bvh.rootJointFrames:
			_bvhTransformers.append(BvhTransformer.new(f))
	
	func update(m : BvhTransformer.ITransformable):
		_bvhTransformers[index].apply(m)
	func isCompatible(other : BvhAnim):
		_bvhTransformers[0].isCompatible(other._bvhTransformers[0])
var fps : float:
	get:
		if not isReady : return 0
		return _anims[_current_anim].fps
		
var frameCount : float:
	get:
		if not isReady : return 0
		return _anims[_current_anim].frameCount
		
var animCount : float:
	get:
		return len(_anims)
		
var animIndex = 0:
	get:
		return _current_anim
	set(v):
		if 0 <= v and v < animCount:  
			_current_anim = v
		
var frameIndex = 0:
	get:
		return _anims[_current_anim].index
	set(v):
		_anims[_current_anim].index = v
		
var radius : float:
	set(v):
		for a in _anims:
			a.radius = v
			
func update(m : BvhTransformer.ITransformable):
	if isReady:
		var f = _anims[_current_anim].update(m)

func get_names():
	if not isReady : return []
	return _anims[animIndex]._bvhTransformers[frameIndex]._transforms.keys()

func addBvh(path : String):
		var file := FileAccess.open(path, FileAccess.READ)
		if file != null:
			var bvh = BvhParser.new()
			var text = file.get_as_text(true)
			file.close()
			bvh.load(text)
			var x = BvhAnim.new(bvh)
			if len(_anims) > 0:
				_anims[0].isCompatible(x)
			
			_anims.append(BvhAnim.new(bvh))
			if _current_anim == -1:
				_current_anim = len(_anims) - 1
				

var isReady : bool:
	get:
		return _current_anim != -1

