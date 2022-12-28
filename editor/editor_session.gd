extends Node

var session_file_path = "user://editor/session"
var session_data = {}

func _ready():
	setup()
	print("session: ", session_data)

func setup():
	var data = Utils.read_json_file(session_file_path)
	if data: 
		session_data = data
	else:
		session_data = {}
		
func get_value(key):
	if session_data.has(key):
		return session_data[key]
	else:
		return null
		
func set_value(key, value):
	session_data[key] = value
	
func save():
	Utils.write_json_file(session_file_path, session_data)

func save_value(key, value):
	set_value(key, value)
	save()
