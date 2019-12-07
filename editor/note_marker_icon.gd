extends Control

var marker
var color = Color(0, 0, 0, 1)

#onready var icon_node = get_node("Icon")
onready var label_node = get_node("Label")
onready var bg = get_node("BgColor")
onready var editor = get_node("/root/Editor")

func _ready():
	#icon_node.set_texture(marker.icon)
	label_node.text = marker.code
	bg.color = marker.color
	bg.width = EDITOR_NOTE_MARKER_C.WIDTH
	bg.height = EDITOR_NOTE_MARKER_C.HEIGHT
	bg.update()

