extends Node


#var label
#var icon_path
#var value

#var icon

var marker_name
var code
var color 

func setup(marker_name, code, color):
	self.marker_name = marker_name
	self.code = code
	self.color = color

	#if File.new().file_exists(icon_path):
	#	icon = load(icon_path)
	#else:
	#	icon = EDITOR_NOTE_MARKER_C.default_icon
