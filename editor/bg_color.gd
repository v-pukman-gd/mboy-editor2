extends Node2D
tool

export var color = Color(0, 0, 0, 1)
export var width = 10
export var height = 10
export var draw_border = true
export var border_width = 1
export var focused = false

func _ready():
	update()

func _draw():
	if draw_border:
		
		draw_rect(Rect2(0,0, width, height), get_border_color())
		draw_rect(Rect2(get_border_width(),get_border_width(), width-get_border_width()*2, height-get_border_width()*2), get_bg_color())
	else:
		draw_rect(Rect2(0,0, width, height), get_bg_color())
		
		
func get_bg_color():
	return color

func get_border_color():
	if focused:
		return Color(color).linear_interpolate(Color(255,0,0), 1)
	else:
		var c = Color(color)
		c.a = 0.2
		return c #Color(color).linear_interpolate(Color(255,255,255, 0.5), 1)

func get_border_width():
	if focused:
		return border_width+1
	else:
		return border_width
