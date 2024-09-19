extends VBoxContainer
class_name Pose_Slider

signal emit_cloths_change (values:Dictionary)

var label_name : String
var slot=""
var object_selected=""
var objects = {}
var item_name :String
var cur_index=0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Label_Container/Label.text = label_name

func emit_cloths():
	var data = {}
	data["object_selected"]=object_selected
	data["slot"]=slot
	data["name"]=$Label_Container/value.get_item_text(cur_index)
	emit_cloths_change.emit(data)

func option_change(selected_index):
	cur_index=selected_index
	object_selected=objects[$Label_Container/value.get_item_text(selected_index)]
	emit_cloths()
func add_item(itemName:String,Item):
	objects[itemName]=Item
	$Label_Container/value.add_item(itemName)
