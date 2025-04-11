extends MarginContainer

@export var collection: Node3D
var humanizer := Live_Humanizer.new()
var skeleton
var character : CharacterBody3D
@export var menu_root: TabContainer
@export var camera:Camera3D
@export var home_button: Button
@export var nameBox : TextEdit
@export var baseMesh : MeshInstance3D
@export var progress : ProgressBar
@export var exportButton:Button
@export var homeButton:Button
@export var saveButton:Button
@export var posLabel:Label
@export var zoomLabel:Label
@export var randomButton:Button
@export var nameLabel:Label
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
var attach_menu = {}
var detailed_poses={}
var bone_categories = {}
var attachment_points = ["LeftHand","RightHand","Head","RightFoot","LeftFoot","Hips","Chest","Root"]
var simple_pose
var start_of_frame = 0
var printed = false
var detailed_poses_pannel
var detailed_shapekey_pannel
var animal_categories={}
var names_to_translate = []

func _ready() -> void:
	$splits.hide()
	$FileDialog.current_dir = "/"
	$FileDialog.use_native_dialog=true
	$FileDialog.access=FileDialog.ACCESS_FILESYSTEM
	OBJExporter.export_started.connect(_on_export_started)
	OBJExporter.export_completed.connect(_on_export_completed)
	OBJExporter.export_progress_updated.connect(_on_export_progress)
	make_animals_menu()
	make_basic_menu()
	make_attachments_menu()
	make_pose_menu()
	make_import_menu()
	make_detailed_menu()
	make_detailed_pose()
	$splits.show()
	make_character("set_lang")

func set_menue_visibility(detailed_shapekeys,detailed_pose_menues):
	menu_root.remove_child(detailed_poses_pannel)
	menu_root.remove_child(detailed_shapekey_pannel)
	if detailed_pose_menues:
		menu_root.add_child(detailed_poses_pannel)
	if detailed_shapekeys:
		menu_root.add_child(detailed_shapekey_pannel)
	for item in names_to_translate:
		if item["target"]:
			item["target"].name = d.ltr(item["key"])
		else:
			print(item["key"])

func set_lang():
	if simple_pose:
		simple_pose.set_lang()
	for categoryName in bone_categories.keys():
		for bone_name in bone_categories[categoryName]:
			detailed_poses[categoryName][bone_name].set_lang()
	for point in attachment_points:
		attach_menu[point].set_lang()
	for cat in equipment_categories.keys():
		equipment_categories[cat].set_lang()
	for shape in shapekey_slider:
		shapekey_slider[shape].set_lang()
	for animal_category in animal_categories.keys():
		animal_categories[animal_category].name = d.ltr(animal_category)
	exportButton.text = d.ltr("exportButton")
	homeButton.text = d.ltr("home")
	saveButton.text = d.ltr("saveButton")
	posLabel.text = d.ltr("positionSlider")
	zoomLabel.text = d.ltr("zoomLabel")
	randomButton.text = d.ltr("randomCharacter")
	nameLabel.text = d.ltr("Name")
		
func make_character(callback=null):
	for n in collection.get_children():
		if n.get_class() == "CharacterBody3D":
			for slot in attachment_points:
				var parent = attach_points[slot].get_parent()
				for mesh in attach_points[slot].get_children():
					mesh.queue_free()
				if parent:
					parent.remove_child(attach_points[slot])
			n.queue_free()
	var config = HumanConfig.new()
	config.targets['gender'] = 0.0
	config.init_macros()
	config.rig = ProjectSettings.get_setting( "addons/humanizer/default_skeleton")
	var body = HumanizerEquipment.new("DefaultBody")
	config.hair_color = Color(0.75,0.75,0.75)
	config.add_equipment(body)
	config.add_equipment(HumanizerEquipment.new("RightEye-LowPolyEyeball"))
	config.add_equipment(HumanizerEquipment.new("LeftEye"))
	equipment_categories["body"].set_selected("DefaultBody")
	equipment_categories["lefteye"].set_selected("LeftEye")
	equipment_categories["righteye"].set_selected("RightEye-LowPolyEyeball")
	humanizer.load_config_async(config)
	character = humanizer.get_CharacterBody3D(false)
	character.name="Character"# No need to translate this one. it is just for debug
	collection.add_child(character)
	var loaded =false
	while not loaded:
		if humanizer.physics_body:
			if humanizer.physics_body.has_node("AnimationTree"):
				humanizer.get_animation_tree_node().queue_free()
				loaded=true
		await get_tree().process_frame
	humanizer.set_vertex_hiding_enabled()
	skeleton = humanizer.get_skeleton_node()
	while not skeleton:
		skeleton = humanizer.get_skeleton_node()
		await get_tree().process_frame
	add_attach_points()
	fix_poses()
	reset_menues()
	if callback:
		var callable = Callable(self,callback)
		callable.call()
func fix_poses():
	skeleton=humanizer.get_skeleton()
	simple_pose.skeleton = skeleton
	for categoryName in detailed_poses.keys():
		for bone_name in detailed_poses[categoryName].keys():
			var bone_config = detailed_poses[categoryName][bone_name]
			var bone_id = skeleton.find_bone(bone_name)
			bone_config.setup(bone_name,skeleton,bone_id)
			bone_config.humanizer = humanizer
	simple_pose.skeleton = skeleton
	simple_pose.humanizer = humanizer
	simple_pose.ping_poses()
func reset_menues():
	for slot in attachment_points:
		attach_menu[slot]._remove_pressed()
	simple_pose.set_default()
	for cat in equipment_categories.keys():
		equipment_categories[cat].set_selected("None")
	equipment_categories["body"].set_selected("DefaultBody")
	equipment_categories["lefteye"].set_selected("LeftEye")
	equipment_categories["righteye"].set_selected("RightEye-LowPolyEyeball")
	for key_name in shapekey_slider.keys():
		shapekey_slider[key_name].reset()
	for categoryName in detailed_poses:
		for bone_name in detailed_poses[categoryName]:
			detailed_poses[categoryName][bone_name].set_sliders()

func make_detailed_menu():
	var pannel = ScrollContainer.new()
	menu_root.add_child(pannel)
	detailed_shapekey_pannel = pannel
	pannel.name = "Details"
	names_to_translate.append({"target":pannel,"key":"Details"})
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
	shapekeys.erase("Custom")
	for categoryName in shapekeys:
		var category_pannel = ScrollContainer.new()
		var label=Label.new()
		label.name=d.ltr(categoryName)
		names_to_translate.append({"target":label,"key":categoryName})
		label.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		category_pannel.add_child(label)
		details_tab.add_child(category_pannel)
		category_pannel.name=d.ltr(categoryName)
		names_to_translate.append({"target":category_pannel,"key":categoryName})
		var category_vbox = VBoxContainer.new()
		category_vbox.set_custom_minimum_size(Vector2(300,0))
		category_vbox.size_flags_horizontal=Control.SIZE_FILL
		category_pannel.add_child(category_vbox)
		var category_options = shapekeys[categoryName]
		for key_name in category_options:
			var slider = load("res://shapekey_slider.tscn").instantiate()
			slider.label_name = key_name
			slider.shapekeys = [key_name]
			slider.set_lang()
			slider.set_value(50)
			slider.change_shapekeys.connect(_set_shapekey)
			category_vbox.add_child(slider)
			shapekey_slider[key_name]=slider

func add_attach_points():
	if len(attach_points.keys())==0:
		## this is for startup
		for slot in attachment_points:
			attach_points[slot] = BoneAttachment3D.new()
			skeleton.add_child(attach_points[slot])
			attach_points[slot].set_bone_name(slot)
	else:
		## This is for every reload.
		for slot in attach_menu.keys():
			attach_menu[slot].set_anchor_point(attach_points[slot])
			if not attach_points[slot].get_parent():
				skeleton.add_child(attach_points[slot])
	
func make_import_menu():
	var pannel = ScrollContainer.new()
	menu_root.add_child(pannel)
	pannel.name = d.ltr("ImportOBJ")
	names_to_translate.append({"target":pannel,"key":"ImportOBJ"})
	var vbox = VBoxContainer.new()
	vbox.size_flags_vertical=Control.SIZE_EXPAND_FILL
	vbox.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	pannel.add_child(vbox)
	for point in attachment_points:
		attach_menu[point] = load("res://attachment.tscn").instantiate()
		attach_menu[point].set_label(point)
		vbox.add_child(attach_menu[point])

func make_attachments_menu():
	var pannel = ScrollContainer.new()
	menu_root.add_child(pannel)
	pannel.name = d.ltr("Equip")
	names_to_translate.append({"target":pannel,"key":"Equip"})
	var vbox = VBoxContainer.new()
	vbox.size_flags_vertical=Control.SIZE_EXPAND_FILL
	vbox.size_flags_horizontal=Control.SIZE_EXPAND_FILL
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
func make_animals_menu():
	var pannel = ScrollContainer.new()
	menu_root.add_child(pannel)
	pannel.name = d.ltr("Features")
	names_to_translate.append({"target":pannel,"key":"Features"})
	var vbox = VBoxContainer.new()
	vbox.size_flags_vertical=Control.SIZE_EXPAND_FILL
	vbox.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	vbox.set_custom_minimum_size(Vector2(300,0))
	pannel.add_child(vbox)
	var shapekeys = HumanizerTargetService.get_shapekey_categories()
	var custom = shapekeys["Custom"]
	var animal_tab = TabContainer.new()
	animal_tab.set_custom_minimum_size(Vector2(300,0))
	animal_tab.size_flags_horizontal=Control.SIZE_FILL
	animal_tab.size_flags_vertical=Control.SIZE_EXPAND_FILL
	vbox.add_child(animal_tab)
	var category_pannel = ScrollContainer.new()
	category_pannel.name = d.ltr("bodyshape")
	names_to_translate.append({"target":category_pannel,"key":"bodyshape"})
	animal_categories = {"body":VBoxContainer.new()}
	animal_tab.add_child(category_pannel)
	category_pannel.add_child(animal_categories["body"])
	for key_name in custom:
		var slider_name = key_name.split("-")[1]
		var animal_category="body"
		if len(key_name.split("-"))>2:
			animal_category = key_name.split("-")[-1]
		if not animal_category in animal_categories.keys():
			category_pannel=ScrollContainer.new()
			category_pannel.size_flags_horizontal=Control.SIZE_EXPAND_FILL
			category_pannel.size_flags_vertical=Control.SIZE_EXPAND_FILL
			animal_tab.add_child(category_pannel)
			category_pannel.name = d.ltr(animal_category)
			names_to_translate.append({"target":category_pannel,"key":animal_category})
			animal_categories[animal_category] = VBoxContainer.new()
			animal_categories[animal_category].size_flags_horizontal=Control.SIZE_EXPAND_FILL
			animal_categories[animal_category].size_flags_vertical=Control.SIZE_EXPAND_FILL
			category_pannel.add_child(animal_categories[animal_category])
		var slider = load("res://shapekey_slider.tscn").instantiate()
		slider.label_name = slider_name
		slider.shapekeys = [key_name]
		slider.set_lang()
		slider.set_value(50)
		slider.change_shapekeys.connect(_set_shapekey)
		animal_categories[animal_category].add_child(slider)
		shapekey_slider[key_name]=slider
		pass
func make_basic_menu():
	var pannel = ScrollContainer.new()
	menu_root.add_child(pannel)
	pannel.name = d.ltr("Traits")
	names_to_translate.append({"target":pannel,"key":"Traits"})
	var vbox = VBoxContainer.new()
	vbox.size_flags_vertical=Control.SIZE_EXPAND_FILL
	vbox.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	vbox.set_custom_minimum_size(Vector2(300,0))
	pannel.add_child(vbox)
	var macros = HumanizerTargetService.get_shapekey_categories()["Macro"]
	var racial = HumanizerMacroService.race_options
	for key_name in macros:
		var slider = load("res://shapekey_slider.tscn").instantiate()
		slider.label_name = key_name
		slider.shapekeys = [key_name]
		slider.set_value(50)
		slider.set_lang()
		slider.change_shapekeys.connect(_set_shapekey)
		vbox.add_child(slider)
		shapekey_slider[key_name]=slider
	var label = Label.new()
	label.text = d.ltr("racial_features")
	vbox.add_child(label)
	for key_name in racial:
		var slider = load("res://shapekey_slider.tscn").instantiate()
		slider.label_name = key_name
		slider.set_lang()
		slider.shapekeys = key_name
		slider.set_value(50)
		slider.change_shapekeys.connect(_set_shapekey)
		vbox.add_child(slider)
		shapekey_slider[key_name]=slider

func make_pose_menu():
	var pannel = ScrollContainer.new()
	menu_root.add_child(pannel)
	pannel.name = d.ltr("SimplePoses")
	names_to_translate.append({"target":pannel,"key":"SimplePoses"})
	var vbox = VBoxContainer.new()
	vbox.size_flags_vertical=Control.SIZE_EXPAND_FILL
	vbox.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	simple_pose = load("res://basic_pose.tscn").instantiate()
	simple_pose.set_lang()
	pannel.add_child(simple_pose)

func make_detailed_pose():
	var pannel = ScrollContainer.new()
	menu_root.add_child(pannel)
	detailed_poses_pannel = pannel
	pannel.name = d.ltr("DetailedPoses")
	names_to_translate.append({"target":pannel,"key":"DetailedPoses"})
	var vbox = VBoxContainer.new()
	vbox.size_flags_vertical=Control.SIZE_EXPAND_FILL
	vbox.size_flags_horizontal=Control.SIZE_EXPAND_FILL
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
		label.name = d.ltr(categoryName)
		names_to_translate.append({"target":label,"key":categoryName})
		label.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		category_pannel.add_child(label)
		pose_tab.add_child(category_pannel)
		category_pannel.name = d.ltr(categoryName)
		names_to_translate.append({"target":category_pannel,"key":categoryName})
		var category_vbox = VBoxContainer.new()
		category_vbox.set_custom_minimum_size(Vector2(300,0))
		category_vbox.size_flags_horizontal=Control.SIZE_FILL
		category_pannel.add_child(category_vbox)
		for bone_name in bone_categories[categoryName]:
			var bone_config = load("res://bone_control.tscn").instantiate()
			bone_config.humanizer = humanizer
			category_vbox.add_child(bone_config)
			detailed_poses[categoryName][bone_name]=bone_config
			simple_pose.position_macro_set.connect(bone_config.set_sliders)
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
	fix_poses()
	add_attach_points()
	simple_pose.ping_poses()

func setup_character(shapekeys:Dictionary):
	humanizer.set_shapekeys(shapekeys)

func _on_rotation_value_changed(value: float) -> void:
	character.rotation.y=TAU*value/100

func _on_position_slider_value_changed(value: float) -> void:
	camera.v_offset=(value*humanizer.get_head_height()*1.2)/100-0.1
	
func _set_equipment(equipment:Dictionary):
	var old_equip=humanizer.human_config.get_equipment_in_slot(equipment["slot"])
	humanizer.show_clothes_vertices()
	await get_tree().process_frame
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
	save_setings["imported_equipment_settings"]={}
	save_setings["equipment_categories"]={}
	save_setings["detailed_poses"]={}
	save_setings["simple_pose"]={}
	for key_name in shapekey_slider.keys():
		save_setings["shapekey_slider"][key_name]=shapekey_slider[key_name].get_value()
	for point_name in attach_menu.keys():
		save_setings["imported_equipment"][point_name]=var_to_bytes_with_objects(attach_menu[point_name].mesh_object)
	for clothing_slot in equipment_categories.keys():
		save_setings["equipment_categories"][clothing_slot]=equipment_categories[clothing_slot].cur_equipment
	save_setings["simple_pose"]=simple_pose.get_save()
	for categoryName in bone_categories:
		save_setings["detailed_poses"][categoryName]={}
		for bone_name in bone_categories[categoryName]:
			save_setings["detailed_poses"][categoryName][bone_name]={}
			save_setings["detailed_poses"][categoryName][bone_name]=detailed_poses[categoryName][bone_name].get_sliders()	
	saveFile.store_var(save_setings)


func load_character_file(characterName:String):
	nameBox.text = characterName
	start_freeze_manager("character load")
	_on_export_started()
	_on_export_progress(0,0,"making_new_character")
	make_character("finish_load")
func finish_load():
	var progress_percentage = 0.05
	var num_sections = 5
	_on_export_progress(0,progress_percentage,"loading_character_file")
	freeze_manager(progress_percentage)
	var characterName = nameBox.text
	print(characterName)
	var path="user://saves/"+characterName+".save"
	var file = FileAccess.open(path, FileAccess.READ)
	progress_percentage=0.10
	_on_export_progress(0,progress_percentage,"loading_character_file")
	var save_setings = file.get_var()
	progress_percentage=0.15
	_on_export_progress(0,progress_percentage,"loading_character_file")
	var step_size=1.0/float(len(shapekey_slider.keys())*num_sections)
	await get_tree().process_frame
	var i = 0
	for clothing_slot in equipment_categories.keys():
		i=i+1
		if clothing_slot in save_setings["equipment_categories"]:
			equipment_categories[clothing_slot].load_equipment(save_setings["equipment_categories"][clothing_slot])
		progress_percentage+=step_size
		if i%10==1:
			await get_tree().process_frame
			_on_export_progress(0,progress_percentage,"loading_cloths_file")
	i=0
	for key_name in shapekey_slider.keys():
		var temp_val = shapekey_slider[key_name].get_value()
		if key_name in save_setings["shapekey_slider"]:
			if temp_val !=save_setings["shapekey_slider"][key_name]:
				shapekey_slider[key_name].set_value(save_setings["shapekey_slider"][key_name])
				shapekey_slider[key_name].slider_drag_ended(save_setings["shapekey_slider"][key_name])
				freeze_manager(progress_percentage)
		i=i+1
		step_size=1.0/float(len(shapekey_slider.keys())*num_sections)
		progress_percentage+=step_size
		if i%100==1:
			_on_export_progress(0,progress_percentage,"setting_character_shapes")
			await get_tree().process_frame
	i=0
	for categoryName in save_setings["detailed_poses"].keys():
		for bone_name in save_setings["detailed_poses"][categoryName].keys():
			await get_tree().process_frame
			save_setings["detailed_poses"][categoryName][bone_name]=detailed_poses[categoryName][bone_name].get_sliders()
	step_size=1.0/float(len(attach_menu.keys())*num_sections)
	for point_name in attach_menu.keys():
		if save_setings["imported_equipment"][point_name]:
			attach_menu[point_name].load_mesh(bytes_to_var_with_objects(save_setings["imported_equipment"][point_name]))
			await get_tree().process_frame
		progress_percentage+=step_size
		_on_export_progress(0,progress_percentage,"importing_equipment")
	simple_pose.set_save(save_setings["simple_pose"])
	await get_tree().process_frame
	simple_pose.ping_poses()
	_on_export_completed("")

func _on_file_dialog_file_selected(file_path: String) -> void:
	_on_save_pressed()
	if len(file_path)>2:
		var surface_tool= SurfaceTool.new()
		for child in character.get_children():
			if child.get_class() == "Skeleton3D":
				for bone in child.get_children():
					for equipMesh in bone.get_children():
						if equipMesh.get_class() == "MeshInstance3D":
							var transformer=equipMesh.global_transform 
							for index in range(equipMesh.mesh.get_surface_count()):
								surface_tool.append_from(equipMesh.mesh, index,transformer)
			elif child.get_class() == "MeshInstance3D":
				var baked_pose : ArrayMesh
				if child.name =="Avatar":
					var mesh 
					for c in character.get_children():
						if c is MeshInstance3D:
							mesh=c
					baked_pose = mesh.bake_mesh_from_current_skeleton_pose()
				var tranformer=Transform3D()
				if "transform" in baked_pose:
					tranformer=baked_pose.transform
				for index in range(baked_pose.get_surface_count()):
					surface_tool.append_from(baked_pose, index,tranformer)
		surface_tool.append_from(baseMesh.mesh, 0,baseMesh.transform)
		var combinedMesh:ArrayMesh=surface_tool.commit()
		OBJExporter.save_mesh_to_files(combinedMesh, file_path)
		load_character_file(nameBox.text)

func _on_export_started():
	$progressContainer.show()
func character_complete():
	$progressContainer.hide()
func _on_export_completed(_obj_file):
	$progressContainer.hide()

func _on_export_progress(_surf_idx, _progress_value,step=""):
	$progressContainer/vbloading/loadingLabel.text = d.ltr(step)
	$progressContainer/vbloading/ProgressBar.value=_progress_value * 100
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
