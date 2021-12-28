extends Node2D

#const NOTE_COLOR = Color(71/255.0, 187/255.0, 255/255.0, 1)
const BORDER_LINE_W = 1
const CELL_SCALE_MIN = 0.5

var is_pressed = false
var is_deleted = false
var dragging = false
var playing = false
var is_active = false

var width_scale = 1
var max_width = EDITOR_BAR_C.CELL_WIDTH
var drag_x_min = 0
var drag_x_max = 0
var last_dragging_y = 0
var start_dragging_y = 0
var updated_scale = 1

var dragging_x = false
var start_dragging_x = 0

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

func _on_control_gui_input(e):  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	if editor and editor.grab_cursor_slider_focus(e):
		return	

	if e is InputEventMouseButton and e.button_index == BUTTON_LEFT:  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
		is_pressed = e.pressed
		if not is_pressed and dragging:
			set_position(Vector2(get_position().x, 0))  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
			dragging = false
			last_dragging_y = 0
			start_dragging_y = 0
		if is_pressed and not is_active:
			editor.set_active_note(self)

	elif e is InputEventMouseButton and e.button_index == BUTTON_RIGHT:  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
		if e.pressed:
			delete()


	if e is InputEventMouseMotion:  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
		if is_pressed:

			#if get_position().y > EDITOR_BAR_C.CELL_HEIGHT:  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
			#	delete()
			#else:
			if Input.is_key_pressed(KEY_SHIFT):
				
				if not dragging_x:
					dragging_x = true
					start_dragging_x = e.position.x
				#var x_diff = round((e.position.x - start_dragging_x)/0.1) * 0.1
				var x_diff = round((e.position.x - start_dragging_x)/float(EDITOR_BAR_C.NOTE_WIDTH_MIN))*EDITOR_BAR_C.NOTE_WIDTH_MIN
				print("x_diff:", x_diff)
				
				self.position += Vector2(x_diff, 0)
				
				if self.position.x < self.drag_x_min:
					self.position.x = self.drag_x_min
				elif self.position.x > self.drag_x_max - get_width():
					self.position.x = self.drag_x_max - get_width()
			else:
				if dragging_x:
					print("dragging end!")
					dragging_x = false
					bar.sort_notes()
					bar.update_notes_width()
					
				
				if e.position.x > get_width():  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
					var w = e.position.x  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
					if w > 0:						
						w = round(w/float(EDITOR_BAR_C.NOTE_WIDTH_MIN)) * EDITOR_BAR_C.NOTE_WIDTH_MIN
						if w > max_width: w = max_width
						set_width(w)
						#var s = round( (w/EDITOR_BAR_C.CELL_WIDTH)/CELL_SCALE_MIN ) * CELL_SCALE_MIN
						#if s >= 1 and s*EDITOR_BAR_C.CELL_WIDTH <= max_width:
						#	width_scale = s
						#	update()
				elif e.position.x < get_width() - EDITOR_BAR_C.CELL_WIDTH:  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
					var w = EDITOR_BAR_C.CELL_WIDTH + e.position.x  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
					if w > 0:
						w = round(w/float(EDITOR_BAR_C.NOTE_WIDTH_MIN)) * EDITOR_BAR_C.NOTE_WIDTH_MIN
						if w < EDITOR_BAR_C.NOTE_WIDTH_MIN: w = EDITOR_BAR_C.NOTE_WIDTH_MIN
						set_width(w)
						#var s = round( (w/EDITOR_BAR_C.CELL_WIDTH)/CELL_SCALE_MIN ) * CELL_SCALE_MIN
						#if s >= CELL_SCALE_MIN and s*EDITOR_BAR_C.CELL_WIDTH <= max_width:
						#	width_scale = s
						#	update()


			#dragging y
			#if e.position.y > last_dragging_y:  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
			#	if not dragging:
			#		start_dragging_y = e.position.y  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
			#		#print("set d y:", start_dragging_y)
			#		dragging = true
			#	set_position(Vector2(get_position().x, e.position.y-start_dragging_y))  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
			#	last_dragging_y = e.position.y  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review

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
