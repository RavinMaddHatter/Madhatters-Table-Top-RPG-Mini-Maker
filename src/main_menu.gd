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
const SETTINGS_FILE_PATH="user://settings.conf"
var configFile
func _ready() -> void:
	var newConfig = ConfigFile.new()
	var err = newConfig.load(SETTINGS_FILE_PATH)
	if err != OK: 
		newConfig.set_value("VOLUME","SLIDER_VALUE",0)
		newConfig.save(SETTINGS_FILE_PATH)
	configFile = newConfig.load(SETTINGS_FILE_PATH)
	volumeSlider.value = newConfig.get_value("VOLUME","SLIDER_VALUE")
	if volumeSlider.value>-30:
		mainVolume.play()
	_on_volume_value_changed(volumeSlider.value)
	characterCreator.home_button.connect("pressed",_main_menu_show)
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
	characterCreator.new_name()
	characterCreator.make_character()

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
	_hide_all()
	characterCreator.show()
	var characterName=saveSelect.get_item_text(saveSelect.get_selected_id())
	characterCreator.load_character_file(characterName)

	
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
