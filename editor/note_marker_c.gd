extends Node

#const default_icon = preload("res://editor/note_marker/icons/default_marker.png")
const COLOR = "ffffff00"
const EXTENDED = "extended"
const ACCENT = "accent"

var HEIGHT = EDITOR_BAR_C.CELL_WIDTH
var WIDTH = EDITOR_BAR_C.CELL_WIDTH

const NoteMarker = preload("res://editor/note_marker.gd")

var markers = []
var marker_names = []

var deleted_markers = []
var updated_markers = []

#func load_markers(data):
#	marker_names = []
#	markers = []
#	for t in data.tracks:
#		for b in t.bars:
#			for n in b.notes:
#				for m in n.markers:
#					if not marker_names.has(m):
#						marker_names.append(m)
#						load_marker(m)
func _ready():
	pass
	
func clear():
	for m in markers:
		m.queue_free()
	markers = []
	marker_names = []

func load_default_markers():
	load_marker({ 'name': ACCENT, 'code': '*', 'color': COLOR })
	load_marker({ 'name': EXTENDED, 'code': '->', 'color': COLOR })

func load_markers(markers_data):
	clear()
	load_default_markers()
	if markers_data:
		for m in markers_data:
			load_marker(m)
		
func load_marker(marker_data):
	if str(marker_data.name) == "":
		return 
		
	if marker_names.has(marker_data.name):
		return
		
	marker_names.append(marker_data.name)
	var marker = NoteMarker.new()
	marker.setup(marker_data.name, marker_data.code, marker_data.color)
	markers.append(marker)
	
func update_marker(marker_data):
	if str(marker_data.name) == "":
		return
	
	var marker = get_marker(marker_data.name) 
	if marker:
		if marker.code != marker_data.code or marker.color != marker_data.color:
			marker.setup(marker_data.name, marker_data.code, marker_data.color)
			updated_markers.append(marker)
	else:
		load_marker(marker_data)
	
func delete_marker(marker_name):
	if marker_names.has(marker_name):
		marker_names.erase(marker_name)
		for m in markers:
			if m.marker_name == marker_name:
				deleted_markers.append(m)
				markers.erase(m)
				break
		
func new_marker():
	var marker = NoteMarker.new()
	marker.setup("", "", COLOR)
	return marker	

func get_marker(name):
	for m in markers:
		if m.marker_name == name:
			return m
	return null
	
func get_markers_data():
	var data = []
	for m in markers:
		data.append({ 
			'name': m.marker_name, 
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