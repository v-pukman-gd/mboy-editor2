extends ConfirmationDialog

signal marker_info_saved

onready var name_input = get_node("VBoxC/NameInput")
onready var code_input = get_node("VBoxC/CodeInput")
onready var color_btn = get_node("VBoxC/ColorBtn")

onready var hide_btn = get_node("VBoxC/HideBtn")
onready var destroy_btn = get_node("VBoxC/DestroyBtn")

var marker

var _name
var code
var color
var minimized
var pending_destroy = false

func _ready():
	pass

func setup(marker):
	self.marker = marker
	if marker != null:
		set_inputs(marker)
	else:
		set_default_inputs()

func apply_inputs():
	_name = str(name_input.get_text())
	code = str(code_input.get_text())
	color = color_btn.color
	minimized = hide_btn.is_pressed()
	pending_destroy = destroy_btn.is_pressed()

func set_inputs(marker):
	name_input.set_text(marker._name)
	code_input.set_text(marker.code)
	color_btn.color = marker.color
	hide_btn.set_pressed(marker.minimized)
	destroy_btn.set_pressed(false)

	hide_btn.show()
	destroy_btn.show()

func set_default_inputs():
	name_input.set_text("")
	code_input.set_text("")
	color_btn.color = ""
	hide_btn.set_pressed(false)
	destroy_btn.set_pressed(false)

	hide_btn.hide()
	destroy_btn.hide()

func _on_dialog_confirmed():
	apply_inputs()
	emit_signal("marker_info_saved")

