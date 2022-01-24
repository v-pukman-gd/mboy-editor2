extends Control

signal value_changed(value)

onready var input = $VBoxC/SpinBox
onready var label = $VBoxC/Label

func _on_spin_box_value_changed(value):
	emit_signal("value_changed", value)


func set_disabled(val):
	input.set_editable(!val)
	if val:
		label.modulate = Color("82ffffff")
	else:
		label.modulate = Color("ffffff")