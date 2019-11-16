extends ConfirmationDialog

signal track_info_saved

onready var instrument_option = get_node("VBoxC/InstrumentOption")
onready var name_input = get_node("VBoxC/NameInput")
onready var color_btn = get_node("VBoxC/ColorBtn")
onready var hide_btn = get_node("VBoxC/HideBtn")
onready var destroy_btn = get_node("VBoxC/DestroyBtn")

var track
var instrument
var track_name
var color
var minimized
var pending_destroy = false

func _ready():
	var index = 0
	for i in EDITOR_TRACK_INSTRUMENT_C.LIST:
		instrument_option.add_item(i, index)
		index += 1


func setup(track):
	self.track = track
	if track != null:
		set_inputs(track)
	else:
		set_default_inputs()


func apply_inputs():
	instrument = EDITOR_TRACK_INSTRUMENT_C.LIST[instrument_option.get_selected()]
	track_name = str(name_input.get_text())
	color = color_btn.color
	minimized = hide_btn.is_pressed()
	pending_destroy = destroy_btn.is_pressed()

func set_inputs(track):
	var index = 0
	for i in EDITOR_TRACK_INSTRUMENT_C.LIST:
		if i == track.instrument:
			break
		index += 1

	instrument_option.select(index)
	name_input.set_text(track.name)
	color_btn.color = track.color
	hide_btn.set_pressed(track.minimized)
	destroy_btn.set_pressed(false)

	hide_btn.show()
	destroy_btn.show()

func set_default_inputs():
	instrument_option.select(0)
	name_input.set_text("")
	color_btn.color = EDITOR_TRACK_C.DEFAULT_COLOR
	hide_btn.set_pressed(false)
	destroy_btn.set_pressed(false)

	hide_btn.hide()
	destroy_btn.hide()

func _on_dialog_confirmed():
	apply_inputs()
	emit_signal("track_info_saved")

