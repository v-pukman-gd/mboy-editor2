extends ConfirmationDialog

onready var marker_info_c = get_node("VBoxC/ScrollContainer/ItemsList")
var marker_info_scn = preload("res://editor/note_marker_info.tscn")

var deleted_markers = []

signal markers_updated

func _ready():
	pass
	#show()

func setup():
	deleted_markers = []

	for c in marker_info_c.get_children():
		c.queue_free()

	for m in EDITOR_NOTE_MARKER_C.markers:
		add_marker_info(m)

func add_marker_info(marker):
	var info = marker_info_scn.instance()
	info.setup(marker)
	info.connect("delete", self, "_on_delete_btn_pressed", [info])
	marker_info_c.add_child(info)

func _on_add_btn_pressed():
	var marker = EDITOR_NOTE_MARKER_C.new_marker()
	add_marker_info(marker)

func _on_delete_btn_pressed(info):
	if info.marker.id == EDITOR_NOTE_MARKER_C.ACCENT or \
		info.marker.id == EDITOR_NOTE_MARKER_C.EXTENDED:
			return

	deleted_markers.append(info.marker)
	for c in marker_info_c.get_children():
		if c == info:
			c.hide()
			break


func _on_dialog_confirmed():
	for m in deleted_markers:
		EDITOR_NOTE_MARKER_C.delete_marker(m.id)

	for info in marker_info_c.get_children():
		if info.visible:
			EDITOR_NOTE_MARKER_C.update_marker(info.get_data())

	EDITOR_NOTE_MARKER_C.redraw_markers()

	emit_signal("markers_updated")

func _on_dialog_about_to_show():
	setup()
