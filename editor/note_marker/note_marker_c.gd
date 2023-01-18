extends Node

const COLOR = "ffffff00"
const EXTENDED = "extended"
const ACCENT = "accent"

var HEIGHT = EDITOR_BAR_C.CELL_WIDTH
var WIDTH = EDITOR_BAR_C.CELL_WIDTH

const NoteMarker = preload("res://editor/note_marker/note_marker.gd")

var markers = []
var ids = []

var deleted_markers = []
var updated_markers = []

func _ready():
	pass

func clear():
	for m in markers:
		m.queue_free()
	
	for m in deleted_markers:
		m.queue_free()
		
	for m in updated_markers:
		m.queue_free()
	
	markers = []
	ids = []
	deleted_markers = []
	updated_markers = []

func load_default_markers():
	load_marker({ 'id': ACCENT, 'code': '*', 'color': COLOR })
	load_marker({ 'id': EXTENDED, 'code': '->', 'color': COLOR })

func load_markers(markers_data):
	if markers_data:
		for m in markers_data:
			load_marker(m)

	if markers.size() == 0:
		load_default_markers()

func load_marker(marker_data):
	if not marker_data.has('id'):
		return

	if str(marker_data.id) == "":
		return

	if ids.has(marker_data.id):
		return

	ids.append(marker_data.id)
	var marker = NoteMarker.new()
	marker.setup(marker_data.id, marker_data.code, marker_data.color)
	markers.append(marker)

func update_marker(marker_data):
	if str(marker_data.id) == "":
		return

	var marker = get_marker(marker_data.id)
	if marker:
		if marker.code != marker_data.code or marker.color != marker_data.color:
			marker.setup(marker_data.id, marker_data.code, marker_data.color)
			updated_markers.append(marker)
	else:
		load_marker(marker_data)

func delete_marker(id):
	if ids.has(id):
		ids.erase(id)
		for m in markers:
			if m.id == id:
				deleted_markers.append(m)
				markers.erase(m)
				break

func new_marker():
	var marker = NoteMarker.new()
	marker.setup("", "", COLOR)
	return marker

func get_marker(id):
	for m in markers:
		if m.id == id:
			return m
	return null

func get_markers_data():
	var data = []
	for m in markers:
		data.append({
			'id': m.id,
			'code': m.code,
			'color': m.color
		})
	return data

func redraw_markers():
	var has_deleted = deleted_markers.size() > 0
	var has_updated = updated_markers.size() > 0

	if has_deleted or has_updated:
		var notes = get_tree().get_nodes_in_group("note")
		for n in notes:
			if has_deleted:
				n.delete_markers(EDITOR_NOTE_MARKER_C.deleted_markers)

			if has_updated:
				n.update_markers()
		deleted_markers = []
		updated_markers = []

func check_marker_usage(id):
	if str(id) == "":
		return false
	return get_tree().get_nodes_in_group("note_marker_%s" % id).size() > 0
