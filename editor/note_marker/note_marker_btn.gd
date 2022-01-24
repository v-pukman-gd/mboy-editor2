extends Control

signal note_marker_btn_pressed

var markers = []
export (String) var label

onready var menu_btn = get_node("MenuButton")
onready var button_node = get_node("MenuButton/Button")
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
	var id = 1
	for m in markers:
		if m.code:
			label = "%s ( %s )" % [m.id, m.code]
		else:
			label = m.id
		menu_btn.get_popup().add_item(label, id)
		id += 1

func _on_option_selected(option_id):
	var id = option_id - 1
	if id >= 0 and id < markers.size():
		var marker = markers[id]
		emit_signal("note_marker_btn_pressed", marker)

func set_disabled(val):
	menu_btn.set_disabled(val)
	button_node.set_disabled(val)
	if val:
		label_node.modulate = Color("82ffffff")
	else:
		label_node.modulate = Color("ffffff")
	
func is_disabled():
	menu_btn.is_disabled()

func _on_Button_pressed():
	button_node.pressed = false
