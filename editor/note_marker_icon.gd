extends Control

var marker

onready var label_node = get_node("Label")
onready var bg = get_node("BgColor")
onready var editor = get_node("/root/Editor")

func _ready():
	self.add_to_group("note_marker_%s" % marker.id)
	
	label_node.text = marker.code if marker.code else marker.id
	bg.color = marker.color
	bg.width = label_node.get_combined_minimum_size().x #EDITOR_NOTE_MARKER_C.WIDTH
	bg.height = EDITOR_NOTE_MARKER_C.HEIGHT
	bg.update()

