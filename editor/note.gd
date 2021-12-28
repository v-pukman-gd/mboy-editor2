extends Node2D

#const NOTE_COLOR = Color(71/255.0, 187/255.0, 255/255.0, 1)
const BORDER_LINE_W = 1
const CELL_SCALE_MIN = 0.5

var is_pressed = false
var is_deleted = false
var playing = false
var is_active = false

var width_scale = 1
var max_width = EDITOR_BAR_C.CELL_WIDTH
var updated_scale = 1
var drag_x_min = 0
var drag_x_max = 0
var dragging_x = false
var start_dragging_at = 0

#var marker_values = []
var markers = []

onready var control = get_node("Control")
onready var markers_c = get_node("MarkersC")
onready var bar = get_node("../")
onready var editor = get_node("/root/Editor")

var marker_icon_scn = preload("res://editor/note_marker/note_marker_icon.tscn")

func _ready():
	set_process(true)
	markers_c.set_position(Vector2(0, EDITOR_BAR_C.CELL_HEIGHT))  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review

func _process(delta):
	if editor and editor.is_playing:
		var note_x = get_global_position().x  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
		var cursor_x = editor.cursor_playback.get_global_position().x  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
		if cursor_x >= note_x and cursor_x <= note_x + max_width * bar.get_scale().x + get_extended_width():
			if not playing:
				playing = true
				update()
		elif playing:
			playing = false
			update()

	elif playing:
		playing = false
		update()
		
func _unhandled_input(e):
	if e is InputEventKey:
		if e.scancode == KEY_SHIFT:
			if not e.pressed:				
				cancel_dragging_x()
				
func cancel_dragging_x():
	if dragging_x:				
		print("***** dragging end! *****")
		dragging_x = false
		start_dragging_at = 0
		bar.sort_notes()
		bar.update_notes_width()	

func is_extended():
	for m in markers:
		if m.id == EDITOR_NOTE_MARKER_C.EXTENDED:
			return true
	return false

# if curr note is extended, return next note visible width
func get_extended_width():
	if is_extended():
		#check next note
		var next_n = bar.get_note_after(get_position().x)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
		if next_n:
			return next_n.max_width
		#check next bar
		var next_b = bar.get_next_bar()
		if next_b:
			var first_n = next_b.get_first_note()
			if first_n:
				return first_n.get_position().x + first_n.max_width  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	return 0


func get_border_color():
	return get_note_color().linear_interpolate(Color(0,0,0), 0.3)

func get_note_color():
	if is_active or playing: return bar.track.color.linear_interpolate(Color(1,1,1), 0.5)
	else: return bar.track.color

func set_active(val):
	is_active = val
	update()

func get_width():
	return EDITOR_BAR_C.CELL_WIDTH * width_scale

# used for import
func set_width(value):
	set_width_scale(value)
	update()
	
func set_width_scale(width):
	self.width_scale = float(width) / EDITOR_BAR_C.CELL_WIDTH

func _draw():
	var rect2 = Rect2(BORDER_LINE_W, BORDER_LINE_W, get_width()-BORDER_LINE_W*2, EDITOR_BAR_C.CELL_HEIGHT-BORDER_LINE_W*2)
	draw_rect(rect2, get_border_color())
	var rect = Rect2(BORDER_LINE_W, BORDER_LINE_W, get_width()-BORDER_LINE_W*3, EDITOR_BAR_C.CELL_HEIGHT-BORDER_LINE_W*3)
	draw_rect(rect, get_note_color())

	control.set_size(Vector2(get_width(), EDITOR_BAR_C.CELL_HEIGHT))

func _on_control_gui_input(e):
	if editor and editor.grab_cursor_slider_focus(e):
		return

	if e is InputEventMouseButton and e.button_index == BUTTON_LEFT:
		is_pressed = e.pressed
		if not is_pressed:
			cancel_dragging_x()
		if is_pressed and not is_active:
			editor.set_active_note(self)

	elif e is InputEventMouseButton and e.button_index == BUTTON_RIGHT:
		if e.pressed:
			delete()

	if e is InputEventMouseMotion:
		if is_pressed:
			# dragging x
			if Input.is_key_pressed(KEY_SHIFT):
				if not dragging_x:
					dragging_x = true
					start_dragging_at = e.position.x 
					
				if dragging_x:
					var x_diff_min = EDITOR_BAR_C.NOTE_WIDTH_MIN
					if Input.is_key_pressed(KEY_ALT): x_diff_min = 1
					var x_diff = round((e.position.x - start_dragging_at)/float(x_diff_min))*x_diff_min
					position.x += x_diff

					if position.x < drag_x_min:
						position.x = drag_x_min
					elif position.x > drag_x_max - get_width():
						position.x = drag_x_max - get_width()
			# scale width
			else:
				if e.position.x > get_width():
					var w = e.position.x 
					if w > 0:
						w = round(w/float(EDITOR_BAR_C.NOTE_WIDTH_MIN)) * EDITOR_BAR_C.NOTE_WIDTH_MIN
						if w > max_width: w = max_width
						if w != get_width():
							set_width(w)
							bar.update_notes_width()
						
				elif e.position.x < get_width() - EDITOR_BAR_C.CELL_WIDTH:
					var w = EDITOR_BAR_C.CELL_WIDTH + e.position.x
					if w > 0:
						w = round(w/float(EDITOR_BAR_C.NOTE_WIDTH_MIN)) * EDITOR_BAR_C.NOTE_WIDTH_MIN
						if w < EDITOR_BAR_C.NOTE_WIDTH_MIN: w = EDITOR_BAR_C.NOTE_WIDTH_MIN
						if w != get_width():
							set_width(w)
							bar.update_notes_width()
						

func delete():
	if not is_deleted:
		is_deleted = true
		bar.delete_note(self)

func set_markers_data(marker_values):
	var markers_list = []
	for value in marker_values:
		var marker = EDITOR_NOTE_MARKER_C.get_marker(value)
		if marker: markers_list.append(marker)
	add_markers(markers_list)

func get_markers_data():
	var marker_values = []
	for m in markers:
		marker_values.append(m.id)
	return marker_values

func add_markers(markers_list):
	for marker in markers_list:
		if not markers.has(marker): markers.append(marker)
		else: markers.erase(marker)
	print(markers)
	update_markers()
	bar.track.update_height()

func delete_markers(markers_list):
	var changed = false
	for marker in markers_list:
		if markers.has(marker):
			markers.erase(marker)
			changed = true
	if changed:
		update_markers()

func update_markers():
	for m in markers_c.get_children():
		markers_c.remove_child(m)

	var i = 0
	for m in markers:
		var marker_icon = marker_icon_scn.instance()
		marker_icon.marker = m
		#marker_icon.color = bar.track.color
		marker_icon.set_position(Vector2(0, i*EDITOR_NOTE_MARKER_C.HEIGHT))  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
		markers_c.add_child(marker_icon)
		i += 1
	markers_c.set_custom_minimum_size(Vector2(EDITOR_NOTE_MARKER_C.WIDTH, markers.size()*EDITOR_NOTE_MARKER_C.HEIGHT))
	update_scale(updated_scale)
	
# don't scale markers
func update_scale(val):
	updated_scale = val
	for m in markers_c.get_children(): m.set_scale(Vector2(1.0/val,1))
