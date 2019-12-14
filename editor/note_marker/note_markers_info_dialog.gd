extends ConfirmationDialog

onready var marker_info_c = get_node("VBoxC/ScrollC/ItemsList")
onready var header_node = get_node("VBoxC/ItemsListHeader")
onready var alert_label = get_node("VBoxC/AlertLabel")
onready var notice_label = get_node("VBoxC/NoticeLabel")

var marker_info_scn = preload("res://editor/note_marker/note_marker_info.tscn")

var deleted_markers = []
var marker_ids_in_use = []

signal markers_updated

func _ready():
	pass

func setup():
	deleted_markers = []
	marker_ids_in_use = []

	for c in marker_info_c.get_children():
		c.hide()
		c.queue_free()

	for m in EDITOR_NOTE_MARKER_C.markers:
		add_marker_info(m)
	toggle_header()
	clear_alert()
	clear_notice()

func add_marker_info(marker):
	var info = marker_info_scn.instance()
	info.setup(marker)
	info.connect("delete", self, "_on_delete_btn_pressed", [info])
	info.connect("id_text_changed", self, "_on_id_text_changed", [info])
	marker_info_c.add_child(info)

func _on_add_btn_pressed():
	var marker = EDITOR_NOTE_MARKER_C.new_marker()
	add_marker_info(marker)
	toggle_header()

func _on_delete_btn_pressed(info):
	deleted_markers.append(info.marker)
	for c in marker_info_c.get_children():
		if c == info:
			c.hide()
			check_usage(info.marker.id)
			break

	toggle_header()

func check_usage(id):
	if EDITOR_NOTE_MARKER_C.check_marker_usage(id):
		if not marker_ids_in_use.has(id):
			marker_ids_in_use.append(id)

	if marker_ids_in_use.size() > 0:
		alert_label.show()
		if marker_ids_in_use.size() == 1:
			alert_label.set_text("%s %s %s" % [tr("te_marker_in_use1"), marker_ids_in_use[0], tr("te_marker_in_use2")])
		else:
			alert_label.set_text("%s %s %s" % [tr("te_markers_in_use1"), PoolStringArray(marker_ids_in_use).join(", "), tr("te_markers_in_use2")])
	else:
		clear_alert()

func clear_alert():
	alert_label.hide()
	alert_label.set_text("")

func check_existence(id):
	if EDITOR_NOTE_MARKER_C.get_marker(id):
		notice_label.show()
		notice_label.set_text("%s %s %s" % [tr("te_marker_exists1"),id,tr("te_marker_exists2")])
	else:
		clear_notice()

func clear_notice():
	notice_label.hide()
	notice_label.set_text("")

func toggle_header():
	var size = 0
	for c in marker_info_c.get_children():
		if c.visible:
			size += 1
			
	if size == 0:
		header_node.hide()
	else:
		header_node.show()

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

func _on_id_text_changed(value, info):
	if str(value) != "":
		check_existence(value)
