extends MarginContainer

@export var collection: Node3D
var humanizer := Live_Humanizer.new()
var skeleton
var character:CharacterBody3D
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
var detailed_poses={}
var bone_categories = {}
var attachment_points = ["LeftHand","RightHand","Head","RightFoot","LeftFoot","Hips","Chest","Root"]
var simple_pose
var start_of_frame = 0
func _physics_process(_delta):
	if humanizer.physics_body.has_node("AnimationTree"):
		var animator=humanizer.get_animation_tree_node()
		animator.queue_free()
	if !character:
		for N in collection.get_children():
			if N is CharacterBody3D:
				character=N
				character.name="Character"
				break 

func _ready() -> void:
	$splits.hide()
	$FileDialog.current_dir = "/"
	$FileDialog.use_native_dialog=true
	$FileDialog.access=FileDialog.ACCESS_FILESYSTEM
	OBJExporter.export_started.connect(_on_export_started)
	OBJExporter.export_completed.connect(_on_export_completed)
	OBJExporter.export_progress_updated.connect(_on_export_progress)
#	
	after_load()

func after_load():
	
	make_character()
	make_menu()
	add_attach_points()
	$splits.show()

func make_character():
	var config = HumanConfig.new()
	config.targets['gender'] = 0.0
	config.init_macros()
	config.eye_color = Color.GREEN
	config.hair_color = Color.PURPLE
	config.eyebrow_color = Color("550055")
	config.rig = ProjectSettings.get_setting( "addons/humanizer/default_skeleton")
	var body = HumanizerEquipment.new("DefaultBody","defaultMat")
	var overlay = HumanizerOverlay.new()
	#overlay.resource_name = "skin_young"
	body.material_config.add_overlay(overlay)
	config.add_equipment(body)
	humanizer.load_config_async(config)	
	var temp = collection.find_child("Character")
	if temp:
		temp.queue_free()
	var character = humanizer.get_CharacterBody3D(false)
	character.name="Character"
	collection.add_child(character)
	HumanizerEditorUtils.set_node_owner(character,self)
	skeleton = humanizer.get_skeleton_node()
	
func add_attach_points():
	for slot in attachment_points:
		attach_points[slot] = BoneAttachment3D.new()
		skeleton.add_child(attach_points[slot])
		attach_points[slot].set_bone_name(slot)
		attach_menu[slot].set_anchor_point(attach_points[slot])

func make_menu():
	make_basic_menu()
	make_detailed_menu()
	make_attachments_menu()
	make_equipment_menu()
	make_pose_menu()
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
	simple_pose = load("res://basic_pose.tscn").instantiate()
	simple_pose.skeleton = humanizer.get_skeleton_node()
	pannel.add_child(simple_pose)

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
	bone_categories = {}
	bone_categories.root = ["Root","Hips"]
	bone_categories.head = ["Neck","Head"]
	bone_categories.torso = ["Spine","Chest","UpperChest"]
	bone_categories.leftArm = ["LeftShoulder","LeftUpperArm","LeftLowerArm","LeftHand"]
	bone_categories.leftHand = ["LeftIndexProximal","LeftIndexIntermediate","LeftIndexDistal",
							"LeftMiddleProximal","LeftMiddleIntermediate","LeftMiddleDistal",
							"LeftLittleProximal","LeftLittleIntermediate","LeftLittleDistal",
							"LeftRingProximal","LeftRingIntermediate","LeftRingDistal",
							"LeftThumbProximal","LeftThumbMetacarpal","LeftThumbDistal"]
	bone_categories.rightArm = ["RightShoulder","RightUpperArm","RightLowerArm","RightHand"]
	bone_categories.rightHand = ["RightIndexProximal","RightIndexIntermediate","RightIndexDistal",
							"RightMiddleProximal","RightMiddleIntermediate","RightMiddleDistal",
							"RightLittleProximal","RightLittleIntermediate","RightLittleDistal",
							"RightRingProximal","RightRingIntermediate","RightRingDistal",
							"RightThumbProximal","RightThumbMetacarpal","RightThumbDistal"]
	bone_categories.leftLeg = ["LeftUpperLeg","LeftLowerLeg","LeftFoot"]
	bone_categories.rightLeg = ["RightUpperLeg","RightLowerLeg","RightFoot"]
	for categoryName in bone_categories:
		detailed_poses[categoryName]={}
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
		for bone_name in bone_categories[categoryName]:
			var bone_config = load("res://bone_control.tscn").instantiate()
			category_vbox.add_child(bone_config)
			var bone_id = skeleton.find_bone(bone_name)
			bone_config.setup(bone_name,skeleton,bone_id)
			simple_pose.position_macro_set.connect(bone_config.set_sliders)
			detailed_poses[categoryName][bone_name]=bone_config
		var spacer=Label.new()
		spacer.name=" "
		spacer.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		category_pannel.add_child(spacer)

func set_pose(_values:Dictionary):
	var skel = humanizer.skeleton
	var bone_id = skel.find_bone(_values.pose)
	var rotVect = Vector3()
	match _values["axis"]:
		"x":
			rotVect.x=1
		"y":
			rotVect.y=1
		"z":
			rotVect.z=1
	var pose = skel.get_bone_pose(bone_id)
	pose=pose.rotated_local(rotVect,_values["value"])
	humanizer.skel.set_bone_pose(bone_id,pose)
	pose = skel.get_bone_pose(bone_id)

func _set_shapekey(shapekey_values:Dictionary):
	humanizer.set_targets(shapekey_values)
func default_settings():
	simple_pose.set_default()
	for key_name in shapekey_slider.keys():
		shapekey_slider[key_name].set_value(0.0)
func setup_character(shapekeys:Dictionary):
	humanizer.set_shapekeys(shapekeys)

func _on_rotation_value_changed(value: float) -> void:
	character.rotation.y=TAU*value/100

func _on_position_slider_value_changed(value: float) -> void:
	camera.v_offset=(value*humanizer.get_head_height()*1.2)/100-0.1
	
func _set_equipment(equipment:Dictionary):
	var old_equip=humanizer.human_config.get_equipment_in_slot(equipment["slot"])
	if old_equip:
		humanizer.remove_equipment(old_equip)
	if equipment["item_name"] !="None":
		humanizer.add_equipment(HumanizerEquipment.new(equipment["item_name"])) 
		

func _on_zoom_slider_value_changed(value):
	var invert=1-value
	zoom_out_size= humanizer.get_head_height()*1.2
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
	var save_setings={}
	save_setings["shapekey_slider"]={}
	save_setings["imported_equipment"]={}
	save_setings["equipment_categories"]={}
	save_setings["detailed_poses"]={}
	save_setings["simple_pose"]={}
	for key_name in shapekey_slider.keys():
		save_setings["shapekey_slider"][key_name]=shapekey_slider[key_name].get_value()
	for point_name in attach_menu.keys():
		save_setings["imported_equipment"][point_name]=var_to_bytes_with_objects(attach_menu[point_name].mesh_object)
	for clothing_slot in equipment_categories.keys():
		save_setings["equipment_categories"]=equipment_categories[clothing_slot].cur_equipment
	save_setings["simple_pose"]=simple_pose.get_save()
	for categoryName in bone_categories:
		save_setings["detailed_poses"][categoryName]={}
		for bone_name in bone_categories[categoryName]:
			save_setings["detailed_poses"][categoryName][bone_name]={}
			save_setings["detailed_poses"][categoryName][bone_name]=detailed_poses[categoryName][bone_name].get_sliders()
	
	
	saveFile.store_var(save_setings)
	$Warning.dialog_text="Saving operation for character %s is completed."%nameBox.text
	$Warning.title="Save Complete"
	$Warning.initial_position=$Warning.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	$Warning.show()



func load_character_file(characterName:String):
	start_freeze_manager("character load")
	nameBox.text = characterName
	make_character()
	var path="user://saves/"+characterName+".save"
	var file = FileAccess.open(path, FileAccess.READ)
	var save_setings = file.get_var()
	var progress_percentage = 0
	var num_sections = 4
	var step_size=1.0/float(len(shapekey_slider.keys())*num_sections)
	_on_export_started()
	for key_name in shapekey_slider.keys():
		var temp_val = shapekey_slider[key_name].get_value()
		if temp_val !=save_setings["shapekey_slider"][key_name]:
			shapekey_slider[key_name].set_value(save_setings["shapekey_slider"][key_name])
			shapekey_slider[key_name].slider_drag_ended(save_setings["shapekey_slider"][key_name])
			freeze_manager(progress_percentage)
		progress_percentage+=step_size
		_on_export_progress(0,progress_percentage)
	step_size=1.0/float(len(attach_menu.keys())*num_sections)
	for point_name in attach_menu.keys():
		if save_setings["imported_equipment"][point_name]:
			attach_menu[point_name].load_mesh(bytes_to_var_with_objects(save_setings["imported_equipment"][point_name]))
			freeze_manager(progress_percentage)
		progress_percentage+=step_size
		_on_export_progress(0,progress_percentage)
	step_size=1.0/float(len(equipment_categories.keys())*num_sections)
	for clothing_slot in equipment_categories.keys():
		if save_setings["equipment_categories"]!="None":
			equipment_categories[clothing_slot].load_equipment(save_setings["equipment_categories"])
			freeze_manager(progress_percentage)
		progress_percentage+=step_size
		_on_export_progress(0,progress_percentage)
	simple_pose.set_save(save_setings["simple_pose"])
	step_size=1.0/float(len(bone_categories.keys())*num_sections)
	for categoryName in bone_categories:
		for bone_name in bone_categories[categoryName]:
			detailed_poses[categoryName][bone_name].set_slider_value(save_setings["detailed_poses"][categoryName][bone_name])
		progress_percentage+=step_size
		freeze_manager(progress_percentage)
	_on_export_completed("")


func scal_pose_equipment(eqipment:MeshInstance3D):
	var out_mesh= ArrayMesh.new()
	var mdt = MeshDataTool.new()
	var mesh_scale = eqipment.scale
	mdt.create_from_surface(eqipment.mesh,0)
	for i in range(mdt.get_vertex_count()):
		var vertex = mdt.get_vertex(i)*mesh_scale
		mdt.set_vertex(i, vertex)
	mdt.commit_to_surface(out_mesh)
	return out_mesh

func _on_file_dialog_file_selected(file_path: String) -> void:
	if len(file_path)>2:
		var mesh = character.find_child("Avatar")
		var surface_tool= SurfaceTool.new()
		for child in character.get_children():
			if child.get_class() == "Skeleton3D":
				for bone in child.get_children():
					for equipMesh in bone.get_children():
						if equipMesh.get_class() == "MeshInstance3D":
							var baked_pose = scal_pose_equipment(equipMesh) 
							var transformer=Transform3D()
							var x = Vector3()
							var y = Vector3()
							var z = Vector3()
							x.x=1
							y.y=1
							z.z=1
							transformer=transformer.rotated(x,equipMesh.rotation.x)
							transformer=transformer.rotated(y,equipMesh.rotation.y)
							transformer=transformer.rotated(z,equipMesh.rotation.z)
							transformer=transformer.translated(equipMesh.position)
							transformer=equipMesh.get_parent().transform*transformer
							surface_tool.append_from(baked_pose, 0,transformer)
			elif child.get_class() == "MeshInstance3D":
				var baked_pose : ArrayMesh
				baked_pose = child.bake_mesh_from_current_skeleton_pose()
				var tranformer=Transform3D()
				if "transform" in baked_pose:
					tranformer=baked_pose.transform
				surface_tool.append_from(baked_pose, 0,tranformer)
		surface_tool.append_from(baseMesh.mesh, 0,baseMesh.transform)
		var combinedMesh:ArrayMesh=surface_tool.commit()
		OBJExporter.save_mesh_to_files(combinedMesh, file_path)

func _on_export_started():
	$progressContainer.show()

func _on_export_completed(_obj_file):
	$progressContainer.hide()

func _on_export_progress(_surf_idx, _progress_value):
	$progressContainer/ProgressBar.value=_progress_value * 100
func _on_export_pressed():
	$FileDialog.show()
func _warning(message:String):
	$Warning.dialog_text=message#
	$Warning.title="WARNING"
	$Warning.initial_position=$Warning.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	$Warning.show()
func start_freeze_manager(_type):
	start_of_frame=Time.get_ticks_msec()
func freeze_manager(progress_percentage):
	Time.get_ticks_msec()
	if Time.get_ticks_msec()-start_of_frame >1000.0/Engine.physics_ticks_per_second :
		start_of_frame=Time.get_ticks_msec()
		_on_export_progress(0,progress_percentage)
		await get_tree().process_frame


func _on_random_pressed() -> void:
	var macros = HumanizerTargetService.get_shapekey_categories()["Macro"]
	var racial = HumanizerMacroService.race_options
	start_freeze_manager("random")
	var num_keys = len(macros)+len(racial)
	var progress_percentage = 0
	for key_name in macros:
		progress_percentage+=1.0/num_keys
		freeze_manager(progress_percentage)
		shapekey_slider[key_name].set_value(randf()*100)
		shapekey_slider[key_name].emit_shapekeys()
	for key_name in racial:
		progress_percentage+=1.0/num_keys
		freeze_manager(progress_percentage)
		shapekey_slider[key_name].set_value(randf()*100)
		shapekey_slider[key_name].emit_shapekeys()
	_on_export_completed("")
