extends Control
@export var mainMenu:MarginContainer
@export var characterCreator:Control
@export var credits : MarginContainer
@export var loadMenu : MarginContainer
@export var saveSelect: OptionButton
@export var confirm : AcceptDialog
@export var settings: MarginContainer
@export var mainVolume : AudioStreamPlayer
@export var volumeSlider:Slider
@export var langSetting:OptionButton
@export var mainTitleLB:Label
@export var loadTitleLB:Label
@export var newCharacterLB:Button
@export var mainNewCharacterBT:Button
@export var mainLoadCharacterBT:Button
@export var mainSettingsBT:Button
@export var mainCreditsBT:Button
@export var assets_lable:Label
@export var load_character_load:Button
@export var load_character_delete:Button
@export var load_character_back:Button
@export var load_character_new:Button
@export var settings_label:Label
@export var settings_volume_label:Label
@export var settings_lang_label:Label
@export var settings_adv_sk_label:Label
@export var settings_adv_pose_label:Label
@export var settings_home_button:Button
@export var quit_button:Button
@export var EquipmentLB:Label
@export var equipVB:VBoxContainer
@export var targVB:VBoxContainer
@export var targLB:Label
@export var modManager:VBoxContainer

const SETTINGS_FILE_PATH="user://settings.conf"
var configFile
var menu_visiblity = {}

func _ready() -> void:
	var newConfig = ConfigFile.new()
	var err = newConfig.load(SETTINGS_FILE_PATH)
	if err != OK: 
		newConfig.set_value("VOLUME","SLIDER_VALUE",0)
		newConfig.set_value("LANG","LANG","automatic")
		newConfig.set_value("ADVANCED","POSES",false)
		newConfig.set_value("ADVANCED","SHAPEKEYS",false)
		newConfig.save(SETTINGS_FILE_PATH)
	configFile = newConfig.load(SETTINGS_FILE_PATH)
	volumeSlider.value = newConfig.get_value("VOLUME","SLIDER_VALUE")
	if volumeSlider.value>-30:
		mainVolume.play()
	menu_visiblity["poses"] = newConfig.get_value("ADVANCED","POSES")
	menu_visiblity["shapekeys"] = newConfig.get_value("ADVANCED","SHAPEKEYS")
	_on_volume_value_changed(volumeSlider.value)
	characterCreator.home_button.connect("pressed",_main_menu_show)
	var language = newConfig.get_value("LANG","LANG")
	langSetting.add_item("automatic",0)
	var langs = TranslationServer.get_loaded_locales()
	for lang in langs:
		langSetting.add_item(TranslationServer.get_language_name(lang)+"-"+lang)
		if lang == language:
			langSetting.select(langSetting.item_count-1)
	if language == "automatic" or not language:
		var preferred_language = OS.get_locale_language()
		TranslationServer.set_locale(preferred_language)
	else:
		TranslationServer.set_locale(language)
	set_lang()
	load_credits()

func load_credits():
	var jsonFile=FileAccess.get_file_as_string("res://assets/citations/basepack/equipment.json")
	var citations_dict = JSON.parse_string(jsonFile)
	for key in citations_dict.keys():
		var author=Label.new()
		author.text=key
		equipVB.add_child(author)
		var margin=MarginContainer.new()
		margin.add_theme_constant_override("margin_left",25)
		equipVB.add_child(margin)
		var creator_vbox = VBoxContainer.new()
		creator_vbox.name = key
		margin.add_child(creator_vbox)
		for citation in citations_dict[key]:
			var entry = Label.new()
			entry.name = citation
			entry.text = d.ltr(citation)
			creator_vbox.add_child(entry)
	jsonFile=FileAccess.get_file_as_string("res://assets/citations/basepack/targets.json")
	citations_dict = JSON.parse_string(jsonFile)
	for key in citations_dict.keys():
		var author=Label.new()
		author.text=key
		targVB.add_child(author)
		var margin=MarginContainer.new()
		margin.add_theme_constant_override("margin_left",25)
		targVB.add_child(margin)
		var creator_vbox = VBoxContainer.new()
		creator_vbox.name = key
		margin.add_child(creator_vbox)
		for citation in citations_dict[key]:
			var entry = Label.new()
			entry.name = citation
			entry.text = d.ltr(citation)
			creator_vbox.add_child(entry)
	
func set_lang():
	mainTitleLB.text = d.ltr("title")
	loadTitleLB.text = d.ltr("title")
	newCharacterLB.text = d.ltr("newChar")
	mainNewCharacterBT.text = d.ltr("newChar")
	mainLoadCharacterBT.text = d.ltr("loadChar")
	mainSettingsBT.text = d.ltr("settings")
	mainCreditsBT.text = d.ltr("credits")
	load_character_load.text = d.ltr("load")
	load_character_delete.text = d.ltr("delete")
	load_character_back.text = d.ltr("back")
	load_character_new.text = d.ltr("newChar")
	settings_label.text = d.ltr("settings")
	settings_volume_label.text = d.ltr("volume")
	settings_home_button.text = d.ltr("home")
	settings_lang_label.text = d.ltr("language")
	settings_adv_sk_label.text = d.ltr("DetailedShapekeys")
	settings_adv_pose_label.text = d.ltr("DetailedPoses")
	quit_button.text = d.ltr("quit")
	assets_lable.text = d.ltr("assets")
	targLB.text = d.ltr("shapekeys")
	characterCreator.set_lang()
	modManager.set_lang()
	for key in d.keys:
		print(key)
func _hide_all():
	mainMenu.hide()
	characterCreator.hide()
	credits.hide()
	loadMenu.hide()
	settings.hide()

func _main_menu_show():
	_hide_all()
	mainMenu.show()

func _credits_show():
	_hide_all()
	credits.show()

func _on_settings_pressed() -> void:
	_hide_all()
	settings.show()

func _on_new_character_pressed() -> void:
	_hide_all()
	characterCreator.show()
	characterCreator.set_menue_visibility(
		menu_visiblity["shapekeys"],
		menu_visiblity["poses"])
	characterCreator.new_name()
	characterCreator.make_character("character_complete")

func _on_show_load_menu():
	saveSelect.clear()
	var dir = DirAccess.open("user://saves/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				if ".save" in file_name:
					saveSelect.add_item(file_name.replace(".save",""))
			file_name = dir.get_next()
	_hide_all()
	loadMenu.show()

func _on_load_character_save():
	var characterName=saveSelect.get_item_text(saveSelect.get_selected_id())
	characterCreator.load_character_file(characterName)
	_hide_all()
	characterCreator.show()
	characterCreator.set_menue_visibility(
		menu_visiblity["shapekeys"],
		menu_visiblity["poses"])

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_delete_pressed() -> void:
	confirm.dialog_text="This will permanantly delete this character, Are you sure?"
	confirm.show()

func _on_confirm_delete_confirmed() -> void:
	var characterName=saveSelect.get_item_text(saveSelect.get_selected_id())
	var path="user://saves/"+characterName+".save"
	DirAccess.remove_absolute(path)
	path="user://saves/"+characterName+".clo"
	DirAccess.remove_absolute(path)
	_on_show_load_menu()

func _on_volume_value_changed(value: float) -> void:
	if value==-30:
		mainVolume.stop()
	elif not(mainVolume.playing):
		mainVolume.play()
	var newConfig = ConfigFile.new()
	newConfig.load(SETTINGS_FILE_PATH)
	newConfig.set_value("VOLUME","SLIDER_VALUE",value)
	newConfig.save(SETTINGS_FILE_PATH)
	mainVolume.volume_db=value

func _on_lang_setting_item_selected(index: int) -> void:
	var value = langSetting.get_item_text(index).split("-")[-1]
	var newConfig = ConfigFile.new()
	newConfig.load(SETTINGS_FILE_PATH)
	newConfig.set_value("LANG","LANG",value)
	newConfig.save(SETTINGS_FILE_PATH)
	TranslationServer.set_locale(value)
	set_lang()

func _on_adv_sk_box_toggled(toggled_on: bool) -> void:
	var newConfig = ConfigFile.new()
	newConfig.load(SETTINGS_FILE_PATH)
	newConfig.set_value("ADVANCED","SHAPEKEYS",toggled_on)
	newConfig.save(SETTINGS_FILE_PATH)
	menu_visiblity["shapekey"] = toggled_on

func _on_adv_pose_box_toggled(toggled_on: bool) -> void:
	var newConfig = ConfigFile.new()
	newConfig.load(SETTINGS_FILE_PATH)
	newConfig.set_value("ADVANCED","POSES",toggled_on)
	newConfig.save(SETTINGS_FILE_PATH)
	menu_visiblity["poses"] = toggled_on
