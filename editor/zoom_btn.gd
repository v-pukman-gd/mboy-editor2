extends VBoxContainer

signal up
signal down

onready var up_btn = $HBoxC/UpBtn
onready var down_btn = $HBoxC/DownBtn
onready var label = $Label

func _on_up_pressed():
	emit_signal("up")
	up_btn.pressed = false

func _on_down_pressed():
	emit_signal("down")
	down_btn.pressed = false
	
func set_disabled(val):
	up_btn.set_disabled(val)
	down_btn.set_disabled(val)
	if val:
		label.modulate = Color("82ffffff")
	else:
		label.modulate = Color("ffffff")
