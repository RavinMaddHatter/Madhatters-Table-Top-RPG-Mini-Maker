extends VBoxContainer
@export var sectionTitle:Label
@export var loadButton:Button
@export var deleteButton:Button
@export var toggleTheme:Theme
@export var modBrowser:FileDialog
@export var packContainer:VBoxContainer
@export var openModFolder:Button
@export var loadedPacksLable:Label
@export var instructions:RichTextLabel
@export var openFolderButton:Button

var items={}
func set_lang() -> void:
	sectionTitle.text = d.ltr("packSection")
	loadButton.text = d.ltr("loadPack")
	loadedPacksLable.text = d.ltr("loadedPacksLabel")
	instructions.clear()
	instructions.add_text(d.ltr("explainLoadingMods")+"\n\n")
	instructions.append_text(d.ltr("explainRemovingMods"))
	openFolderButton.text = d.ltr("openFolder")
	#instructions.append_text(ProjectSettings.globalize_path("user://humanizer"))
	
func _ready() -> void:
	set_lang()
	modBrowser.current_dir = "/"
	modBrowser.use_native_dialog=true
	modBrowser.set_filters(["*.zip"])
	modBrowser.file_mode=FileDialog.FILE_MODE_OPEN_FILE
	modBrowser.access=FileDialog.ACCESS_FILESYSTEM
	var dir = DirAccess.open("user://humanizer")
	if not dir:
		dir = DirAccess.open("user://")
		dir.make_dir("user://humanizer")
	addButtonsToContainer()
func addButtonsToContainer() -> void:
	var dir = DirAccess.open("user://humanizer")
	var files = dir.get_files()
	for file in files:
		add_item(file)
func add_item(file):
	var item = Label.new()
	item.text = file
	item.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item.theme = toggleTheme
	items[file]=item
	packContainer.add_child(items[file])

func _on_load_pressed() -> void:
	modBrowser.show()

func _on_mod_browser_file_selected(path: String) -> void:
	var fileName = path.get_file()
	var dir = DirAccess.open("user://humanizer")
	dir.copy(path,"user://humanizer/"+fileName)
	add_item(fileName)

func _on_open_folder_pressed() -> void:
	OS.shell_open(ProjectSettings.globalize_path("user://humanizer"))
