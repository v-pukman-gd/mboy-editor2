extends "res://editor/btn.gd"

var playing = false

func _ready():
	set_playing(false)

func set_playing(value):
	playing = value
	if playing == false:
		icon_label.icon = "play"
		label.set_text("te_play")
	else:
		icon_label.icon = "stop"
		label.set_text("te_stop")

