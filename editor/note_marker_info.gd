extends VBoxContainer

signal delete

var marker_name_input = "VBoxC/HBoxC/VBoxC/NameEdit"
var code_input = "VBoxC/HBoxC/VBoxC2/CodeEdit"
var color_btn = "VBoxC/HBoxC/VBoxCr3/ColorBtn"

var marker

func get_data():
	return {
		'name': get_node(marker_name_input).text,
		'code': get_node(code_input).text,
		'color': get_node(color_btn).color.to_html()
	}
		
func setup(marker):
	self.marker = marker
	set_inputs()
	
func set_inputs():
	get_node(marker_name_input).text = marker.marker_name 
	get_node(code_input).text = marker.code
	get_node(color_btn).color = marker.color
	if marker.marker_name != "":
		get_node(marker_name_input).editable = false

func _on_delete_btn_pressed():
	emit_signal("delete")
