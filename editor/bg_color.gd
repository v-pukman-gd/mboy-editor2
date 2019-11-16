extends Node2D
tool
export var color = Color(0, 0, 0, 1)
export var width = 10
export var height = 10

func _ready():
	update()

func _draw():
	draw_rect(Rect2(0,0, width, height), color)


