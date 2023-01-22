extends Node2D

var quarters_count = EDITOR_BAR_C.QUARTERS_COUNT #4 is default
var index = 0

onready var grid = get_node("Grid")
onready var index_label = get_node("IndexLabel")
onready var control = get_node("Control")
onready var track = get_node("../../")
onready var editor = get_node("/root/Editor")

var note_scn = preload("res://editor/note.tscn")

var notes = []
var x_pos = 0

func _ready():
	index_label.set_text(str(index))
	control.set_custom_minimum_size(Vector2(get_width(), get_height()))

func get_width(): return get_cells_count() * EDITOR_BAR_C.CELL_WIDTH
func get_grid_height(): return EDITOR_BAR_C.CELL_HEIGHT
func get_height(): return ( get_grid_height() + get_max_markers_count() * EDITOR_NOTE_MARKER_C.HEIGHT )
func get_cells_count(): return quarters_count * EDITOR_BAR_C.CELLS_IN_QUARTER_COUNT

func get_max_markers_count():
	var c = 0
	for n in notes:
		if n.markers.size() > c:
			c = n.markers.size()
	return c

func set_x_position(val):  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	x_pos = val
	set_position(Vector2(x_pos, 0))  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review

func update_scale(val):

	# used scale_d
	#set_scale(Vector2(get_scale().x*val, 1))
	#set_position(Vector2(get_position().x*val, get_position().y))  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	#index_label.set_scale(Vector2(index_label.get_scale().x/val,1))

	set_scale(Vector2(val, 1))
	set_position(Vector2(x_pos * val, get_position().y))  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	index_label.set_scale(Vector2(1.0/val,1))
	for n in notes: n.update_scale(val)

func _on_control_gui_input(e):  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	# mobile support
	# https://godotengine.org/qa/4341/drag-and-drop-2d-objects-on-touchscreen
	# if event is InputEventScreenTouch:  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	# elif event is InputEventMouseButton:  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	#print("e g pos", e.global_pos)

	if editor and editor.grab_cursor_slider_focus(e):
		return

	# if e.is_action_pressed("editor_click"):
	if (e is InputEventMouseButton and e.button_index == BUTTON_LEFT and e.pressed) or (e is InputEventScreenTouch):  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
		#print("bar "+str(index)+" Clicked at", e.position)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review

		var i = floor( e.position.x/float(EDITOR_BAR_C.CELL_WIDTH) )  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
		var x = int(i * EDITOR_BAR_C.CELL_WIDTH)
		if is_cell_empty_at(x):
			var note = add_note(x)
			editor.set_active_note(note)
		else:
			print("NOT EMPTY!")

func add_note(x):
	var n = note_scn.instance()
	n.set_position(Vector2(x, 0))  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	notes.append(n)
	add_child(n)
	sort_notes()
	update_notes_width()
	return n

func clear_notes():
	for n in notes: remove_child(n)
	notes = []

func set_notes_data(notes_data):
	clear_notes()
	for data in notes_data:
		var x = int(int(data.pos)/EDITOR_BAR_C.CELL_EXPORT_SCALE)
		var n = add_note(x)
		n.set_width(int(data.len)/EDITOR_BAR_C.CELL_EXPORT_SCALE)
		n.set_markers_data(data.markers)

func get_notes_data():
	var notes_data = []
	for n in notes:
		notes_data.append({
			pos = n.get_position().x * EDITOR_BAR_C.CELL_EXPORT_SCALE,  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
			len = n.get_width() * EDITOR_BAR_C.CELL_EXPORT_SCALE,
			markers = n.get_markers_data()
		})
	return notes_data

func sort_notes():
	for i in range(notes.size()-1, -1, -1):
		for j in range(1,i+1,1):
			if notes[j-1].get_position().x > notes[j].get_position().x:  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
				var t = notes[j-1]
				notes[j-1] = notes[j]
				notes[j] = t

func is_cell_empty_at(x):
	for n in notes:
		if x >= n.get_position().x and x < n.get_position().x + n.get_width():  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
			return false

	return true

func update_notes_width():	
	for n in notes:
		set_note_borders(n)
		
func set_note_borders(note):
	#print("set_note_borders:")
	var cells_after = []
	var cells_before = []
	var note_x = note.position.x
	
	for n in notes:
		if n.position.x > note_x:
			cells_after.append(n)
		elif n.position.x < note_x:
			cells_before.append(n)
			
	var left = 0
	if cells_before.size() > 0:
		var note_max = cells_before[0]
		for nn in cells_before:
			if nn.position.x > note_max.position.x: note_max = nn
		left = note_max.position.x + note_max.get_width()
		
	var right = self.get_width() 
	if cells_after.size() > 0:
		var note_min = cells_after[0]
		for nn in cells_after:
			if nn.position.x < note_min.position.x: note_min = nn
		right = note_min.position.x
		
	note.drag_x_min = left
	note.drag_x_max = right
	note.max_width = right - note_x
	
	if note.max_width < note.get_width():
		note.set_width_scale(note.max_width)
	
	#print("L:", note.drag_x_min, "R:", note.drag_x_max, "W:", note.max_width)

func delete_note(note):
	remove_child(note)
	notes.erase(note)
	editor.unset_active_note()
	update_notes_width()

func get_first_note():
	if notes.size() == 0: return null
	var first = notes[0]
	for n in notes:
		if n.get_position().x < first.get_position().x:  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
			first = n
	return first

func get_next_bar():
	if track.bars.size() > index + 1:
		return track.bars[index+1]
	else: return null

func get_note_after(x_pos):
	if notes.size() > 0:
		var next = []
		for n in notes:
			if n.get_position().x > x_pos:  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
				next.append(n)
		if next.size() > 0:
			var first = next[0]
			for nn in next:
				if nn.get_position().x < first.get_position().x:  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
					first = nn
			return first
	return null


