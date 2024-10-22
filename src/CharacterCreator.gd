extends MarginContainer
@export var humanizer:HumanizerEditorTool
@export var collection: Node3D
@export var menu_root: TabContainer
@export var camera:Camera3D
@export var home_button: Button
@export var nameBox : TextEdit
@export var baseMesh : MeshInstance3D
@export var progress : ProgressBar
var rng = RandomNumberGenerator.new()
var camera_zoom = 0
var zoom_in_offset = 0
var zoom_out_offset = -.10
var zoom_in_size = .25
var zoom_out_size = 3
var zoom_mid_ratio = 0
var zoom_mid_offset = 0
var shapekey_slider = {}
var equipment_categories = {}
var attach_points = {}
var attach_menu ={}
var attachment_points = ["LeftHand","RightHand","Head","RightFoot","LeftFoot","Hips","Chest"]
func _ready() -> void:
	make_menu()
	make_character()
	$FileDialog.current_dir = "/"
	$FileDialog.use_native_dialog=true
	$FileDialog.access=FileDialog.ACCESS_FILESYSTEM
	OBJExporter.export_started.connect(_on_export_started)
	OBJExporter.export_completed.connect(_on_export_completed)
	OBJExporter.export_progress_updated.connect(_on_export_progress)
	#HelperFunctions.import_bvh("res://assets/poses/Snek_01.bvh")

func make_character():
	humanizer.reset()
	humanizer.remove_equipment(HumanizerEquipment.new("DefaultBody","none_diffuse"))
	humanizer.add_equipment(HumanizerEquipment.new("DefaultBody","none_diffuse"))
	humanizer.add_equipment(HumanizerEquipment.new("RightEyeball-LowPoly"))
	humanizer.add_equipment(HumanizerEquipment.new("LeftEyeBall-LowPoly"))
	humanizer.get_node("AnimationTree").active=false
	var skelton = humanizer.skeleton
	for slot in attachment_points:
		attach_points[slot] = BoneAttachment3D.new()
		skelton.add_child(attach_points[slot])
		attach_points[slot].set_bone_name(slot)
		attach_menu[slot].set_anchor_point(attach_points[slot])
	

func make_menu():
	make_basic_menu()
	make_attachments_menu()
	make_equipment_menu()
	make_pose_menu()
	make_detailed_menu()
	make_detailed_pose()

func make_detailed_menu():
	var pannel = ScrollContainer.new()
	menu_root.add_child(pannel)
	pannel.name = "Details"
	var vbox = VBoxContainer.new()
	vbox.size_flags_vertical=Control.SIZE_EXPAND_FILL
	pannel.add_child(vbox)
	var details_tab = TabContainer.new()
	details_tab.set_custom_minimum_size(Vector2(300,0))
	details_tab.size_flags_horizontal=Control.SIZE_FILL
	details_tab.size_flags_vertical=Control.SIZE_EXPAND_FILL
	vbox.add_child(details_tab)
	var shapekeys = HumanizerTargetService.get_shapekey_categories()
	shapekeys.erase("Macro")
	shapekeys.erase("Race")
	for categoryName in shapekeys:
		var category_pannel = ScrollContainer.new()
		var label=Label.new()
		label.name=categoryName.capitalize()
		label.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		category_pannel.add_child(label)
		details_tab.add_child(category_pannel)
		category_pannel.name=categoryName
		var category_vbox = VBoxContainer.new()
		category_vbox.set_custom_minimum_size(Vector2(300,0))
		category_vbox.size_flags_horizontal=Control.SIZE_FILL
		category_pannel.add_child(category_vbox)
		var category_options = shapekeys[categoryName]
		for key_name in category_options:
			var slider = load("res://shapekey_slider.tscn").instantiate()
			slider.label_name = key_name
			slider.shapekeys = [key_name]
			slider.set_value(50)
			slider.change_shapekeys.connect(_set_shapekey)
			category_vbox.add_child(slider)
			shapekey_slider[key_name]=slider
func make_equipment_menu():
	var pannel = ScrollContainer.new()
	menu_root.add_child(pannel)
	pannel.name = "Equipment"
	var vbox = VBoxContainer.new()
	vbox.size_flags_vertical=Control.SIZE_EXPAND_FILL
	pannel.add_child(vbox)
	
	for point in attachment_points:
		attach_menu[point] = load("res://attachment.tscn").instantiate()
		attach_menu[point].set_label(point)
		vbox.add_child(attach_menu[point])

func make_attachments_menu():
	var pannel = ScrollContainer.new()
	menu_root.add_child(pannel)
	pannel.name = "Body Parts/Cloths"
	var vbox = VBoxContainer.new()
	vbox.size_flags_vertical=Control.SIZE_EXPAND_FILL
	pannel.add_child(vbox)
	equipment_categories = {}
	for item in HumanizerRegistry.equipment:
		var slots = HumanizerRegistry.equipment[item].slots
		for cat in slots:
			if not(cat in equipment_categories):
				equipment_categories[cat] = load("res://equip_menu.tscn").instantiate()
				equipment_categories[cat].set_slot(cat)
				equipment_categories[cat].change_equipment.connect(_set_equipment)
				vbox.add_child(equipment_categories[cat])
				if cat != "Body":
					equipment_categories[cat].add_entry("None")
				else:
					equipment_categories[cat].cur_equipment="DefaultBody"
			equipment_categories[cat].add_entry(item)

func make_basic_menu():
	var pannel = ScrollContainer.new()
	menu_root.add_child(pannel)
	pannel.name = "Basic Config"
	var vbox = VBoxContainer.new()
	vbox.size_flags_vertical=Control.SIZE_EXPAND_FILL
	vbox.set_custom_minimum_size(Vector2(300,0))
	pannel.add_child(vbox)
	var macros = HumanizerTargetService.get_shapekey_categories()["Macro"]
	var racial = HumanizerMacroService.race_options
	for key_name in macros:
		var slider = load("res://shapekey_slider.tscn").instantiate()
		slider.label_name = key_name
		slider.shapekeys = [key_name]
		slider.set_value(50)
		slider.change_shapekeys.connect(_set_shapekey)
		vbox.add_child(slider)
		shapekey_slider[key_name]=slider
	var label = Label.new()
	label.text = "--Racial Features--"
	vbox.add_child(label)
	for key_name in racial:
		var slider = load("res://shapekey_slider.tscn").instantiate()
		slider.label_name = key_name
		slider.shapekeys = key_name
		slider.set_value(50)
		slider.change_shapekeys.connect(_set_shapekey)
		vbox.add_child(slider)
		shapekey_slider[key_name]=slider

func make_pose_menu():
	var pannel = ScrollContainer.new()
	menu_root.add_child(pannel)
	pannel.name = "Basic Poses"
	var vbox = VBoxContainer.new()
	vbox.size_flags_vertical=Control.SIZE_EXPAND_FILL
	pannel.add_child(vbox)

func make_detailed_pose():
	var pannel = ScrollContainer.new()
	menu_root.add_child(pannel)
	pannel.name = "Detailed Poses"
	var vbox = VBoxContainer.new()
	vbox.size_flags_vertical=Control.SIZE_EXPAND_FILL
	pannel.add_child(vbox)
	var pose_tab = TabContainer.new()
	pose_tab.set_custom_minimum_size(Vector2(300,0))
	pose_tab.size_flags_horizontal=Control.SIZE_FILL
	pose_tab.size_flags_vertical=Control.SIZE_EXPAND_FILL
	vbox.add_child(pose_tab)
	var  categories = {}
	categories.root = ["Root","Hips"]
	categories.head = ["Neck","Head"]
	categories.torso = ["Spine","Chest","UpperChest"]
	categories.leftArm = ["LeftShoulder","LeftUpperArm","LeftHand"]
	categories.leftHand = ["LeftIndexProximal","LeftIndexIntermediate","LeftIndexDistal",
							"LeftMiddleProximal","LeftMiddleIntermediate","LeftMiddleDistal",
							"LeftLittleProximal","LeftLittleIntermediate","LeftLittleDistal",
							"LeftRingProximal","LeftRingIntermediate","LeftRingDistal",
							"LeftThumbProximal","LeftThumbMetacarpal","LeftThumbDistal"]
	categories.rightArm = ["RightShoulder","RightUpperArm","RightHand"]
	categories.rightHand = ["RightIndexProximal","RightIndexIntermediate","RightIndexDistal",
							"RightMiddleProximal","RightMiddleIntermediate","RightMiddleDistal",
							"RightLittleProximal","RightLittleIntermediate","LittleDistal",
							"RightRingProximal","RightRingIntermediate","RightRingDistal",
							"RightThumbProximal","RightThumbMetacarpal","RightThumbDistal"]
	categories.leftLeg = ["LeftUpperLeg","LeftLowerLeg","LeftFoot"]
	categories.rightLeg = ["RightUpperLeg","RightLowerLeg","RightFoot"]
	for categoryName in categories:
		var category_pannel = ScrollContainer.new()
		var label=Label.new()
		label.name=categoryName.capitalize()
		label.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		category_pannel.add_child(label)
		pose_tab.add_child(category_pannel)
		category_pannel.name=categoryName
		var category_vbox = VBoxContainer.new()
		category_vbox.set_custom_minimum_size(Vector2(300,0))
		category_vbox.size_flags_horizontal=Control.SIZE_FILL
		category_pannel.add_child(category_vbox)
		for bone_name in categories[categoryName]:
			for axis in ["x","y","z"]:
				var slider = load("res://pose_slider.tscn").instantiate()
				slider.label_name = bone_name + " / " + axis
				slider.pose = bone_name
				slider.axis = axis
				slider.change_pose.connect(set_pose)
				category_vbox.add_child(slider)
		var spacer=Label.new()
		spacer.name=" "
		spacer.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		category_pannel.add_child(spacer)

func set_pose(_values:Dictionary):
	var skeleton = humanizer.skeleton
	var bone_id = skeleton.find_bone(_values.pose)
	var rotVect = Vector3()
	match _values["axis"]:
		"x":
			rotVect.x=1
		"y":
			rotVect.y=1
		"z":
			rotVect.z=1
	var pose = skeleton.get_bone_pose(bone_id)
	pose=pose.rotated_local(rotVect,_values["value"])
	humanizer.skeleton.set_bone_pose(bone_id,pose)
	pose = skeleton.get_bone_pose(bone_id)

func _set_shapekey(shapekey_values:Dictionary):
	humanizer.set_shapekeys(shapekey_values)

func setup_character(shapekeys:Dictionary):
	humanizer.set_shapekeys(shapekeys)
	

func _on_rotation_value_changed(value: float) -> void:
	humanizer.rotation.y=TAU*value/100

func _on_position_slider_value_changed(value: float) -> void:
	camera.v_offset=(value*humanizer.humanizer.get_head_height()*1.2)/100-0.1
	
func _set_equipment(equipment:Dictionary):
	humanizer.remove_equipment_in_slot(equipment["slot"])
	if equipment["item_name"] !="None":
		humanizer.add_equipment(HumanizerEquipment.new(equipment["item_name"],"none_diffuse"))

func _on_zoom_slider_value_changed(value):
	var invert=1-value
	zoom_out_size= humanizer.humanizer.get_head_height()*1.2
	camera.size = zoom_out_size*invert
func new_name():
	nameBox.text = make_name()


const values ={"Vowel": ["a","e","i","o","u","y"],
			"DoubleVowel": ["au", "oa", "ou", "ie", "ae", "eu"],
			"Consonent":["b", "c", "d", "f", "g", "h", "j", "l", "m", "n", "p", "r", "s", "t", "v", "w", "x", "z" ],
			"doubeCons" :["mm", "nn", "st", "ch", "ll", "tt", "ss"],
			"compose":["gu", "cc", "sc", "tr", "fr", "pr", "br", "cr", "ch", "gn", "ix", "an", "do", "ir", "as"]}
	
const transitions={"initial":["Vowel","Consonent","compose"],
					"Vowel":["Consonent","doubeCons","compose"],
					"DoubleVowel":["Consonent","doubeCons","compose"],
					"Consonent":["Vowel","DoubleVowel"],
					"doubeCons":["Vowel","DoubleVowel"],
					"compose":["Vowel"]}
	
func make_name():
	var length = rng.randi_range(5, 12)
	var charname=""
	var index=0
	var state = "initial"
	while index < length:
		var obj = _get_letter(state,length-index)
		state=obj[0]
		var lastLetter = obj[1]
		charname += lastLetter
		index += len(lastLetter)
	return charname.capitalize()
		
func _get_letter(state, max_length):
	var options = transitions[state]
	var new_state = options[rng.randi_range(0, len(options)-1)]
	while max_length<3 and new_state in ["compose","DoubleVowel","Consonent"]:
		new_state = options[rng.randi_range(0, len(options)-1)]
	var letter = values[new_state][rng.randi_range(0, len(values[new_state])-1)]
	return [new_state,letter]
	
func _on_save_pressed():
	var dir = DirAccess.open("user://")
	if not(dir.dir_exists("user://saves")):
		DirAccess.make_dir_absolute("user://saves")
	var saveFile = FileAccess.open("user://saves/%s.save" % nameBox.text,FileAccess.WRITE)
	saveFile.store_var(humanizer.humanizer.human_config.targets)
	var clothsFile = FileAccess.open("user://saves/%s.clo" % nameBox.text,FileAccess.WRITE)
	var equip_dict = {}
	for item in equipment_categories:
		equip_dict[equipment_categories[item].slot]=equipment_categories[item].cur_equipment
	clothsFile.store_var(equip_dict)
	$Warning.dialog_text="Saving operation for character %s is completed."%nameBox.text
	$Warning.title="Save Complete"
	$Warning.initial_position=$Warning.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	$Warning.show()

func _warning(message:String):
	$Warning.dialog_text=message#
	$Warning.title="WARNING"
	$Warning.initial_position=$Warning.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	$Warning.show()

func load_character_file(characterName:String):
	make_character()
	var path="user://saves/"+characterName+".save"
	var file = FileAccess.open(path, FileAccess.READ)
	var clothesFile = FileAccess.open("user://saves/"+characterName+".clo", FileAccess.READ)
	var shapekeys = file.get_var()
	var equip_dict = clothesFile.get_var()
	if not(equip_dict):
		equip_dict = {}
	setup_character(shapekeys)
	for slot in equip_dict:
		_set_equipment({"item_name":equip_dict[slot],"slot":slot})

func _on_export_pressed():
	$FileDialog.show()
	var file_path = $FileDialog.current_file
	if len(file_path)>2:
		_on_save_pressed()
		humanizer.bake_textures=false
		humanizer.set_bake_meshes('Opaque')
		humanizer.bake_surface()
		var mesh = humanizer.find_child("Baked-Opaque").mesh
		var surface_tool= SurfaceTool.new()
		surface_tool.append_from(mesh, 0,humanizer.transform)
		surface_tool.append_from(baseMesh.mesh, 0, baseMesh.transform)
		var combinedMesh:ArrayMesh=surface_tool.commit()
		OBJExporter.save_mesh_to_files(combinedMesh, file_path)
		_warning("Poses not currently supported. The default pose was exported.")
		make_character()
		load_character_file(nameBox.text)  
		humanizer.get_node("AnimationTree").active=false  

func _on_export_started():
	pass
func _on_export_completed(_obj_file):
	pass
func _on_export_progress(_surf_idx, _progress_value):
	#progress.value=_progress_value
	pass
