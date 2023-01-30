extends Popup

func _ready():
	show_tutorial_popup()
	
func show_tutorial_popup():
	var tutorial_clicked = EditorSession.get_value("tutorial_clicked", false)
	if not tutorial_clicked:
		popup_centered()
		
func play_tutorial():
	EditorSession.save_value("tutorial_clicked", true)
	OS.shell_open(EDITOR_C.TUTORIAL_URL)
	hide()

func _on_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			play_tutorial()

func _on_SkipBtn_pressed():
	hide()
