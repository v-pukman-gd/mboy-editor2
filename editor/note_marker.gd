extends Node


var label
var icon_path
var value

var icon

func setup(label, icon_path, value):
	self.label = label
	self.icon_path = icon_path
	self.value = value

	if File.new().file_exists(icon_path):
		icon = load(icon_path)
	else:
		icon = EDITOR_NOTE_MARKER_C.default_icon
