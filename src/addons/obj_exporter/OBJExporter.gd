extends Node
var scale=26
signal export_started
signal export_progress_updated(surf_idx, progress_value)
signal export_completed(object_file, material_file)

# Dump given mesh to obj file
func save_mesh_to_files(mesh: Mesh, file_path: String):
	# Based on:
	# https://github.com/fractilegames/godot-obj-export/blob/main/objexport.gd
	# https://github.com/mohammedzero43/CSGExport-Godot/blob/master/addons/CSGExport/csgexport.gd
	var startTime = Time.get_unix_time_from_system()
	emit_signal("export_started")
	var object_name:String=file_path.split("/")[-1].split("\\")[-1].split(".")[0]
	if not(".obj" in file_path):
		file_path+=".obj"

	var output = "o %s\n"%object_name
	var index_base = 1
	var vertFormat = "v %s %s %s\n"
	var uvFormat = "vt %s %s \n"
	var formatNorm="vn %s %s %s\n"
	
	for s in range(mesh.get_surface_count()):
		emit_signal("export_progress_updated", s, 0)
		var surface = mesh.surface_get_arrays(s)
		if surface[ArrayMesh.ARRAY_INDEX] == null:
			push_warning("Saving only supports indexed meshes for now, skipping non-indexed surface " + str(s))
			continue
		
		var mat: StandardMaterial3D = mesh.surface_get_material(s)
		output += "g surface%s\n"%[s]
		print(len(surface[ArrayMesh.ARRAY_VERTEX]))
		var temp = ""
		for v in surface[ArrayMesh.ARRAY_VERTEX]:
			temp += vertFormat % [v.x*scale, v.y*scale, v.z*scale]
			if len(temp)>50000:
				output += temp
				temp = ""
		output += temp
		# Write triangle faces
		# Note: Godot's front face winding order is different from obj file format
		var i = 0
		var indices = surface[ArrayMesh.ARRAY_INDEX]
		var indices_count = indices.size()
		var faceFormat="f %s %s %s\n"
		temp = ""
		while i < indices_count:
			temp += faceFormat%[index_base + indices[i],
									index_base + indices[i+2],
									index_base + indices[i+1]]
			
			if (i % 900) == 0: # Modulo must be multiple of 3 as it's the step
				output+=temp
				temp=""
				emit_signal("export_progress_updated", s, i / float(indices_count))
				await get_tree().process_frame
			i += 3
		
		emit_signal("export_progress_updated", s, 1.0)
		
		index_base += surface[ArrayMesh.ARRAY_VERTEX].size()
	
	var obj_file := file_path
	print(obj_file)
	var file_obj = FileAccess.open(obj_file, FileAccess.WRITE)
	file_obj.store_string(output)
	emit_signal("export_completed", obj_file)#, mat_file)
	print("Elapsed Time:")
	print(Time.get_unix_time_from_system()-startTime)


func load_mesh_from_file(filename: String, material_filename: String = "") -> Mesh:
	# Transparent call to Ezcha's gd-obj
	
	return ObjParse.load_obj(filename, material_filename)
