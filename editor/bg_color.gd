extends Node2D
tool

export var color = Color("ffff00")
export var width = 10
export var height = 10
export var border_width = 1

export var radius = 0
export var focused = false
var focus_color = Color("1bfe99")
export var border_color = Color(1,1,1)
export var border_value = 0.7

func _ready():
	update()

func _draw():
	var style_box = StyleBoxFlat.new()
	style_box.set_corner_radius_all(radius)
	style_box.bg_color = get_bg_color()
	style_box.border_color = get_border_color()
	style_box.border_width_top = get_border_width()
	style_box.border_width_right = get_border_width()
	style_box.border_width_bottom = get_border_width()
	style_box.border_width_left = get_border_width()
	draw_style_box(style_box, Rect2(Vector2(0,0), Vector2(width, height)))
		
func get_bg_color():
	return color

func get_border_color():
	#if focused:
	#	return focus_color
	#else:
	return Color(get_bg_color()).linear_interpolate(border_color, border_value)

func get_border_width():
	if focused:
		return border_width
	else:
		# keep same for now
		return border_width
