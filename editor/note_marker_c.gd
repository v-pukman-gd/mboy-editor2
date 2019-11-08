extends Node

const default_icon = preload("res://editor/note_marker/icons/default_marker.png")

#var markers = []
#var marker_values = []
#
#const ACCENT = "accent"
#const EPIC = "epic"
const EXTENDED = "extended"
#const MIX = "mix"
#const AUTOPLAY = "autoplay"
#
#var MARKERS_LIST = [
#	ACCENT,
#	EPIC,
#	EXTENDED,
#	MIX,
#	AUTOPLAY
#]
#
#var ICONS = {
#	ACCENT: "legal",
#	EPIC: "bomb",
#	EXTENDED: "long-arrow-right",
#	MIX: "share-alt",
#	AUTOPLAY: "car"
#}
#
#var HEIGHT = EDITOR_BAR_C.CELL_WIDTH
#var WIDTH = EDITOR_BAR_C.CELL_WIDTH
#
#func add_marker(marker):
#	if not marker_values.has(marker.value):
#		markers.append(marker)
#		marker_values.append(marker.value)
#
#func get_icon(value):
#	for m in markers:
#		if m.value == value:
#			if File.new().file_exists(m.icon_path):
#				return load(m.icon_path)
#			return null
#	return null

var HEIGHT = EDITOR_BAR_C.CELL_WIDTH
var WIDTH = EDITOR_BAR_C.CELL_WIDTH

const NoteMarker = preload("res://editor/note_marker.gd")

var markers_path = "res://editor/note_marker/markers"
var markers = []
#TODO: add a tool for custom markers creation
# "user://editor/note_marker/markers"
var custom_markers_path = "res://editor/custom_note_marker/markers"
var custom_markers = []
var marker_values = []
#var custom_marker_values = []

func load_markers(file_path):
	var file = File.new()
	if file.open(file_path, File.READ) != 0:
		print("Error opening file for load markers")
		print(file_path)
		return []

	var data = {}
	data.parse_json(file.get_as_text())
	if data.has("markers"):
		return data["markers"]
	else:
		return []

func _ready():
	var list

	list = load_markers(markers_path)
	for m in list:
		if not marker_values.has(m.value):
			marker_values.append(m.value)
			var marker = NoteMarker.new()
			marker.setup(m.label, m.icon_path, m.value)
			markers.append(marker)

	list = load_markers(custom_markers_path)
	for m in list:
		if not marker_values.has(m.value):
			marker_values.append(m.value)
			var marker = NoteMarker.new()
			marker.setup(m.label, m.icon_path, m.value)
			custom_markers.append(marker)

func get_marker(value):
	for m in markers:
		if m.value == value:
			return m
	for m in custom_markers:
		if m.value == value:
			return m
	return null

