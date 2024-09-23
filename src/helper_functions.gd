extends Node

func import_bvh(file_name:String):
	var file = FileAccess.open(file_name, FileAccess.READ)
	var content = file.get_as_text()
	var loaded_object={}
	if content:
		content=content.replace("\r","\n")
		var lines = content.split("\n")
		var root_lin=get_root(lines)
		loaded_object=parse_object(lines,root_lin+1,"root")
	print(loaded_object)
func get_root(lines:Array):
	for i in range(len(lines)):
		if "root" in lines[i]:
			return i
func parse_object(lines,idx,next_child=""):
	var object={}
	for line_idx in range(len(lines)-idx):
		var line=lines[line_idx+idx]
		if "JOINT" in line:
			next_child = line.replace("JOINT","").strip_edges()
		if "{" in line:
			object[next_child]=parse_object(lines,line_idx+idx+1)
		if "OFFSET" in line:
			var temp  = []
			for text in line.replace("OFFSET","").strip_edges().split(" "):
				temp.append(text.to_float())
			object["OFFSET"]=temp
		if "}" in line:
			return object
		if "CHANNELS" in line:
			object["CHANNELS"]=[]
			for text in line.replace("CHANNELS","").strip_edges().split(" "):
				if not(text.is_valid_int()):
					object["CHANNELS"].append(text)
	
