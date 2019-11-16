extends Control

const LABEL_LEFT_OFFSET = 20
const LABEL_H = 20

var instrument = EDITOR_TRACK_INSTRUMENT_C.OTHER
var track_name = ""
var color = EDITOR_TRACK_C.DEFAULT_COLOR

var bars = []
var bars_data
var bars_count = 0
var real_size
var start_pos = 0
var curr_scale = 1

var name_updated = false
var size_updated = false
var start_pos_updated = true
var is_active = false
var minimized = false

var bar_scn = preload("res://editor/bar.tscn")
onready var name_label = get_node("NameC/BgColor/NameLabel")
onready var name_bg = get_node("NameC/BgColor")
onready var bars_c = get_node("BarsC")
onready var editor = get_node("/root/Editor")

func _ready():
	spawn_bars()
	update_name()
	set_process(true)

func _process(delta):
	#name label length fix
	if not name_updated:
		update_name()
		name_updated = true

	if real_size != null and not size_updated:
		update_size()
		size_updated = true

	if not start_pos_updated:
		update_start_position()  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
		start_pos_updated = true

func setup(bars_count, update_existing=false):
	self.bars_count = bars_count
	if update_existing: respawn_bars()

func spawn_bars():
	clear_bars()
	var x = 0
	#parse imported
	if bars_data != null:
		for data in bars_data:
			var bar = add_bar(x, int(data.index), int(data.quarters_count))
			bar.set_notes_data(data.notes)
			x += bar.get_width()
	#add new
	else:
		for i in range(bars_count):
			var bar = add_bar(x, i, EDITOR_BAR_C.QUARTERS_COUNT)
			x += bar.get_width()

func respawn_bars():
	var curr_bars_count = bars.size()
	if curr_bars_count < bars_count:
		var x = bars[curr_bars_count-1].get_position().x + bars[curr_bars_count-1].get_width()  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
		for i in range(bars_count):
			if i >= curr_bars_count:
				var bar = add_bar(x, i, EDITOR_BAR_C.QUARTERS_COUNT)
				x += bar.get_width()

		print("curr_bars_count < bars_count", " bars count:", bars.size())
	elif curr_bars_count > bars_count:
		for i in range(curr_bars_count):
			if i >= bars_count: bars_c.remove_child(bars[i])

		bars.resize(bars_count)
		print("curr_bars_count > bars_count", " bars count:", bars.size())

func set_info(track_info):
	instrument = track_info.instrument
	track_name = track_info.track_name
	color = track_info.color
	if not minimized and track_info.minimized:
		real_size = get_custom_minimum_size()
	minimized = track_info.minimized
	name_updated = false
	size_updated = false

func update_size():
	if minimized:
		set_custom_minimum_size(Vector2(0, LABEL_H))
		bars_c.hide()
	else:
		set_custom_minimum_size(real_size)
		bars_c.show()

func get_height():
	return EDITOR_TRACK_C.TRACKS_DISTANCE + get_max_bar_height()

func get_full_name():
	if track_name != "": return track_name
	else: return instrument

func get_label_color():
	if is_active: return color.linear_interpolate(Color(1,1,1), 0.5)
	else: return color

func update_name():
	name_label.set_text(get_full_name())
	name_bg.color = get_label_color()
	#name_bg.color.a = 0.9
	name_bg.width = name_label.get_size().x
	name_bg.height = name_label.get_size().y
	name_bg.update()

func update_scale(val):
	curr_scale = val
	for b in bars:
		b.update_scale(val)
	bars_c.set_position(Vector2(start_pos*val, bars_c.get_position().y))  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review

func clear_bars():
	for b in bars: bars_c.remove_child(b)
	bars = []

func add_bar(x, index, quarters_count):
	var bar = bar_scn.instance()
	bar.index = index
	bar.quarters_count = quarters_count
	bar.set_x_position(x)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	bars.append(bar)
	bars_c.add_child(bar)
	return bar

#IMPORT/EXPORT
func get_data():
	var bars_data = []
	for b in bars:
		bars_data.append({
			index = b.index,
			quarters_count = b.quarters_count,
			notes = b.get_notes_data()
		})

	return {
		instrument = instrument,
		name = track_name,
		color = color.to_html(),
		bars = bars_data
	}

func set_data(track_data):
	instrument = track_data.instrument
	track_name = track_data.name
	color = Color(track_data.color)
	bars_data = track_data.bars
	name_updated = false

func set_start_position(val):  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	start_pos = val
	start_pos_updated = false

func update_start_position():  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	bars_c.set_position(Vector2(start_pos*curr_scale, bars_c.get_position().y))  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review

func move_label(val):
	name_label.get_parent().set_position(Vector2(val+LABEL_LEFT_OFFSET, name_label.get_position().y))  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review

func update_height():
	set_custom_minimum_size(Vector2(get_size().x, get_height()))
	editor.update_cursor_length()

func get_max_bar_height():
	var max_h = 0
	for b in bars:
		var h = b.get_height()
		if h > max_h: max_h = h
	return max_h


func _on_name_control_gui_input(e):  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	if editor and editor.grab_cursor_slider_focus(e):
		return

	#if e.is_action_pressed("editor_click"):
	if (e is InputEventMouseButton and e.button_index == BUTTON_LEFT and e.pressed) or (e is InputEventScreenTouch):  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
		if is_active: editor.unset_active_track()
		else: editor.set_active_track(self)

func set_active(val):
	is_active = val
	name_bg.color = get_label_color()
	name_bg.update()

