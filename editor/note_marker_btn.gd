extends Control

signal note_marker_btn_pressed

var markers = []

#export (String, "Default", "Custom") var type = "Default"
export (String) var label

#onready var option_btn = get_node("OptionButton")
onready var menu_btn = get_node("MenuButton")
onready var label_node = get_node("Label")

func _ready():
	label_node.set_text(tr(label))
	
func setup():
	clear_options()
	
	self.markers = EDITOR_NOTE_MARKER_C.markers
	set_options()
	menu_btn.get_popup().connect("id_pressed", self, "_on_option_selected")

func clear_options():
	menu_btn.get_popup().clear()

func set_options():
	#option_btn.clear()
	#option_btn.add_item("", 0)
	#option_btn.set_item_disabled(0, true)
	var id = 1
	for m in markers:
		#option_btn.add_item(str(m.code) + " " + str(m.marker_name), id)
		label = str(m.code) + " " + str(m.marker_name)
		menu_btn.get_popup().add_item(label, id)
		id += 1

	#option_btn.set_text_align(1)
	

func _on_option_selected(option_id):
	var id = option_id - 1
	if id >= 0 and id < markers.size():
		var marker = markers[id]
		emit_signal("note_marker_btn_pressed", marker)
	#option_btn.select(0)

func set_disabled(val):
	menu_btn.set_disabled(val)
	#option_btn.set_disabled(val)


