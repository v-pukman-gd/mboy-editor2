extends VBoxContainer

#just test an idea of option with icons
#use it later if needed

onready var option = get_node("OptionButton")

func _ready():
	option.add_item("\uf270", 0)
	option.add_item("\uf0f9", 1)
	option.add_item("\uf2a3", 2)
