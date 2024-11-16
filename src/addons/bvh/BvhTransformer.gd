

class_name BvhTransformer


class ITransformable:
	func get_name(): return  ""
	func apply(transform : Transform3D, length : float): pass

# Dictionary[String, transform]
var _transforms = { }

class transform:
	var parent : transform
	var name : String
	var p1 : Vector3
	var p2 : Vector3
	var length : float
#	var capsule_radius : float
	var tr : Transform3D
	func _init(parent : transform, name: String, p1 : Vector3, p2 : Vector3):
		self.parent = parent
		self.name = name
		self.p1 = p1
		self.p2 = p2
		
	func compute():
		var v : Vector3 = p2 - p1
		var l =  v.length()
		length = l
		tr = Transform3D()
		if l > 0:
			var vn = v / l
			var a = Vector3(0, 1, 0).angle_to(vn)
			tr = tr.translated(Vector3(0, l * 0.5, 0))
			tr = tr.rotated(Vector3(0, 1, 0).cross(vn).normalized(), a)
		tr = tr.translated(p1)
	func isCompatible(other : transform) -> bool:
		if name != other.name: 
			print("name: %s != %s" % [name, other.name])
			return false
		if p1 != other.p1: 
			print("p1: %o != %o" % [p1, other.p1])
			return false
		if p2 != other.p2: 
			print("p2: %o != %o" % [p2, other.p2])
			return false
		if parent != null and other.parent != null:
			return parent.isCompatible(other.parent)
		return parent == null and other.parent == null

func isCompatible(other : BvhTransformer) -> bool:
	for itemK in _transforms:
		var otherItem = other._transforms.get(itemK)
		if otherItem == null:
			print("missing " + itemK)
			return false
		if _transforms[itemK].isCompatible(otherItem):
			return false
	return true


func _apply(parent : transform, children : Array[BvhParser.BvhJoint], pParent : Vector3, qParent : Quaternion):
	for c in children:
		var p = pParent + qParent * c.offset + c.position
		var item = transform.new(parent, c.name, pParent, p)
		_transforms[c.name] = item
		_apply(item, c.children, p, qParent * c.rotation)
func compute():
	for x in _transforms:
		_transforms[x].compute()
		
func apply(m : BvhTransformer.ITransformable):
	var name = m.get_name()
	var tr = _transforms[name]
	m.apply(tr.tr, tr.length)

		
func _init(bvhJ : BvhParser.BvhJoint):
	var p = bvhJ.offset + bvhJ.position
	var item = transform.new(null, bvhJ.name, p, p)
	_transforms[bvhJ.name] = item
	_apply(item, bvhJ.children, p, bvhJ.rotation)
	compute()
