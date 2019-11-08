extends Control

signal note_marker_btn_pressed

var markers = []

export (String, "Default", "Custom") var type = "Default"
export (String) var label

onready var option_btn = get_node("OptionButton")
onready var label_node = get_node("Label")

func _ready():
	if type == "Custom":
		markers = EDITOR_NOTE_MARKER_C.custom_markers
	else:
		markers = EDITOR_NOTE_MARKER_C.markers
	set_options()
	label_node.set_text(tr(label))


func set_options():
	#option_btn.clear()
	option_btn.add_icon_item(EDITOR_NOTE_MARKER_C.default_icon, "", 0)
	option_btn.set_item_disabled(0, true)
	var id = 1
	for m in markers:
		option_btn.add_icon_item(m.icon, m.label, id)
		id += 1

	option_btn.set_text_align(1)

func _on_option_item_selected(option_id):
	var id = option_id - 1
	if id >= 0 and id < markers.size():
		var marker = markers[id]
		emit_signal("note_marker_btn_pressed", marker)
	option_btn.select(0)

func set_disabled(val):
	option_btn.set_disabled(val)

