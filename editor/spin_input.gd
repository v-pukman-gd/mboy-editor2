extends Control

signal value_changed(value)

onready var input = get_node("VBoxC/SpinBox")

func _on_spin_box_value_changed(value):
	emit_signal("value_changed", value)
