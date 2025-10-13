extends Node2D

signal selectedNotes(notes)

var dragging = false  # Are we currently dragging?
var selected = []  # Array of selected units.
var drag_start = Vector2.ZERO  # Location where drag began.

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			# We only want to start a drag if there's no selection.
			if selected.size() == 0:
				dragging = true
				drag_start = event.position
		elif dragging:
			# Button released while dragging.
			dragging = false
			update()
			checkForOverlappingNotes()
	if event is InputEventMouseMotion and dragging:
		update()

func checkForOverlappingNotes():
	var rect = Rect2(drag_start, get_global_mouse_position() - drag_start)
	var noteSelection : Array
	
	#Check if it is worth checking
	if rect.size.abs() < Vector2(0.1, 0.1):
		return
	
	#Look through every note to see if it is in the selection
	var notes = get_tree().get_nodes_in_group("note")
	for note in notes:
		if rect.has_point(note.global_position):
			noteSelection.append(note)
	
	emit_signal("selectedNotes", noteSelection)

func _draw():
	if dragging:
		draw_rect(Rect2(drag_start, get_global_mouse_position() - drag_start), Color.yellow, false, 2.0)
