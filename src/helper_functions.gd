extends Node

class BvhJoint:
	var name : String
	var parent : BvhJoint
	var offset := Vector3(0,0,0)
	var children : Array[BvhJoint]
	var position := Vector3(0,0,0)
	var rotation := Quaternion()
	
func quat(r : Vector3) -> Quaternion:
	var q1 = Quaternion(Vector3(1,0,0), deg_to_rad(r.x))
	var q2 = Quaternion(Vector3(0,1,0), deg_to_rad(r.y))
	var q3 = Quaternion(Vector3(0,0,1), deg_to_rad(r.z))
	return q3 * q2 * q1 #best best	

func read_bvh(file_path):
	var bvh_file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	var lines = bvh_file.get_as_text().split("\n", false)
	
	var index = 1
	for line in lines:
		index += 1
		print(line)
		
