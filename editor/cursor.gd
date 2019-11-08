extends Node2D

const DEFAULT_LENGTH_OFFSET = 30

var speed = 0
var speed_scale = 1
var curr_speed = 0

var length = EDITOR_C.WAVEFORM_H
var length_offset = 0

func _ready():
	set_process(true)



func start():
	curr_speed = speed

func stop():
	curr_speed = 0

func _process(delta):
	move_local_x(curr_speed*speed_scale*delta)

func set_length_offset(val):
	length_offset = val
	update()


func _draw():
	draw_line(Vector2(0,0), Vector2(0, length+length_offset+DEFAULT_LENGTH_OFFSET), Color(255, 255, 255), 2)

