extends Node


#var label
#var icon_path
#var value

#var icon

var id
var code
var color

func setup(id, code, color):
	self.id = id
	self.code = code
	self.color = color

	#if File.new().file_exists(icon_path):
	#	icon = load(icon_path)
	#else:
	#	icon = EDITOR_NOTE_MARKER_C.default_icon
