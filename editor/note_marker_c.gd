extends Node

const default_icon = preload("res://editor/note_marker/icons/default_marker.png")

const EXTENDED = "extended"
const ACCENT = "accent"

var HEIGHT = EDITOR_BAR_C.CELL_WIDTH
var WIDTH = EDITOR_BAR_C.CELL_WIDTH

const NoteMarker = preload("res://editor/note_marker.gd")

var markers = []
var marker_names = []

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

func load_markers(markers_data):
	#append default markers
	load_marker({ 'name': ACCENT, 'code': '*', 'color': '' })
	load_marker({ 'name': EXTENDED, 'code': '->', 'color': '' })
	
	#append custom markers
	if markers_data:
		for m in markers_data:
			load_marker(m)
		
						
func load_marker(marker_data):
	if not marker_names.has(marker_data.name):
		marker_names.append(marker_data.name)

		var marker = NoteMarker.new()
		marker.setup(marker_data.name, marker_data.code, marker_data.color)
		markers.append(marker)

func get_marker(name):
	for m in markers:
		if m.marker_name == name:
			return m
	return null