# Reads mh target files to collect and cache data for all shapekeys
class_name ShapeKeyReader
extends RefCounted

var shapekey_data := {}

# Process the shape key data.
func run():
	print('Collecting shape key data from target files')
	
	#clean shapekey folder
	for path in OSPath.get_files("res://addons/humanizer/data/resources/shapekey/"):
		DirAccess.remove_absolute(path)
	
	shapekey_data = {}
	
	# Load helper mesh and index vertices
	var helper_mesh: ArrayMesh = load('res://addons/humanizer/data/resources/base_helpers.res')
	var helper_vertices = helper_mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
	var mh2gd_index = HumanizerUtils.get_mh2gd_index_from_mesh(helper_mesh)

	# Make basis shapekey
	shapekey_data.basis = []
	for mh_index in mh2gd_index.size():
		var g_index = mh2gd_index[mh_index][0]
		var coords = helper_vertices[g_index]
		shapekey_data.basis.append(coords)

	# Get individual shapekey data
	shapekey_data.shapekeys = {}
	for path in HumanizerGlobalConfig.config.asset_import_paths:
		_get_shape_keys(path + 'targets/')
	
	shapekey_data.macro_shapekeys = []
	for category in shapekey_data.shapekeys:
		for sk in shapekey_data.shapekeys[category]:
			if sk.begins_with('african') or sk.begins_with('asian') or sk.begins_with('caucasian')\
					or sk.begins_with('female') or sk.begins_with('male') or sk.begins_with('universal'):
				shapekey_data.macro_shapekeys.append(sk)
			
	var base_data_file := FileAccess.open("res://addons/humanizer/data/resources/shapekey/_base_data.dat", FileAccess.WRITE)
	base_data_file.store_var(shapekey_data.basis)
	base_data_file.store_var(shapekey_data.macro_shapekeys)
	base_data_file.close()
	
	for category in shapekey_data.shapekeys:
		var file := FileAccess.open("res://addons/humanizer/data/resources/shapekey/" + category + ".dat", FileAccess.WRITE)
		file.store_var(shapekey_data.shapekeys[category])
		file.close()
		
	HumanizerUtils._shapekey_data = HumanizerUtils.get_shapekey_data()
	print('Finished collecting shapekey data')

func _process_shapekey(path: String, category:String):
	var shape_name = path.get_file().get_basename()
	shapekey_data.shapekeys[category][shape_name] = {}
	var target_file = FileAccess.open(path, FileAccess.READ)

	while target_file.get_position() < target_file.get_length():
		var line = target_file.get_line()
		if line.begins_with('#'):
			continue
		var floats = line.split_floats(" ")
		var sk_index = int(floats[0])
		var sk_coords = Vector3(floats[1],floats[2],floats[3])
		sk_coords *= 0.1 # Original scale
		shapekey_data.shapekeys[category][shape_name][sk_index] = sk_coords
		
func _get_shape_keys(path, category=""):
	var contents = OSPath.get_contents(path)
	for dir in contents.dirs:
		if category == "":
			_get_shape_keys(dir,dir.get_file())
		else:
			_get_shape_keys(dir,category + "_" + dir.get_file())
	for file in contents.files:
		if file.get_extension() == 'target':
			if category not in shapekey_data.shapekeys:
				shapekey_data.shapekeys[category] = {}
			_process_shapekey(file,category)
