#tool
extends Control

signal btn_pressed

export(String) var label_text = "Btn"
export(String) var icon_name = "flag"
export(String) var tooltip_text

onready var container = get_node("VBoxC")
onready var btn = get_node("VBoxC/Button")
onready var icon_label = get_node("VBoxC/Button/FontAwesome")
onready var label = get_node("VBoxC/Label")

func _ready():
	if tooltip_text:
		btn.set_tooltip(str(tooltip_text))
	icon_label.icon = icon_name
	label.set_text(str(label_text))
	#set_custom_minimum_size(container.get_size())
	#container.set_position(Vector2(0,0))  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review

func _on_button_pressed():
	emit_signal("btn_pressed")
	btn.pressed = false

func set_disabled(val):
	btn.set_disabled(val)
	if val:
		label.modulate = Color("82ffffff")
	else:
		label.modulate = Color("ffffff")

func is_disabled():
	btn.is_disabled()
