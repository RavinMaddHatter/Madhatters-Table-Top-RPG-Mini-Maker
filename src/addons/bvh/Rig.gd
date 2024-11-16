@tool
extends Node3D

var _current_index = -1

var _current_bvh_path : String = ""
var _invalidate = false

class Transformer extends BvhTransformer.ITransformable:
	var m : MeshInstance3D
	func _init(m : MeshInstance3D):
		self.m = m
	func apply(transform : Transform3D, length : float):
		var capsule = m.mesh
		m.transform = transform
		if capsule is CapsuleMesh:
			capsule.radius = 1.5
			capsule.height = length + 2.0 * capsule.radius
	func get_name(): 
		return self.m.name

var _manager = BvhManager.new()
var _transformers : Array[Transformer]
func _ready():
	for c in get_children():
		remove_child(c)
		c.queue_free()
	
	_manager.addBvh("res://example.bvh")
	for name in _manager.get_names():
		var m = MeshInstance3D.new()
		m.name = name
		m.mesh = CapsuleMesh.new()
		add_child(m)
		m.set_owner(get_tree().edited_scene_root)
		_transformers.append(Transformer.new(m))
		

func _process(delta):
	if _invalidate:
		_invalidate = false
		for t in _transformers:
			_manager.update(t)
			
var isReady : bool:
	get:
		return _manager.isReady
var fps : float:
	get:
		return _manager.fps
var frameCount : int:
	get:
		return _manager.frameCount
var animCount : int:
	get:
		return _manager.animCount
var frameIndex : int:
	set(v):
		_invalidate = true
		_manager.frameIndex = v
var animIndex : int:
	set(v):
		_invalidate = true
		_manager.animIndex = v
