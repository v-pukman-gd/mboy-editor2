extends VBoxContainer

signal delete

var id_input = "VBoxC/HBoxC/VBoxC/IdEdit"
var code_input = "VBoxC/HBoxC/VBoxC2/CodeEdit"
var color_btn = "VBoxC/HBoxC/VBoxCr3/ColorBtn"

var marker

func get_data():
	return {
		'id': get_node(id_input).text,
		'code': get_node(code_input).text,
		'color': get_node(color_btn).color.to_html()
	}

func setup(marker):
	self.marker = marker
	set_inputs()

func set_inputs():
	get_node(id_input).text = marker.id
	get_node(code_input).text = marker.code
	get_node(color_btn).color = marker.color
	if marker.id != "":
		get_node(id_input).editable = false

func _on_delete_btn_pressed():
	emit_signal("delete")
