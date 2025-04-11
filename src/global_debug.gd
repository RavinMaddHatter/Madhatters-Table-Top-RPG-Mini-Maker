extends Node
var debug = false
var keys = []
func ltr(stringValue:String):
	if not (stringValue in keys) and debug:
		keys.append(stringValue)
	return tr(stringValue)
