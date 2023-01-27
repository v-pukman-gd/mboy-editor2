extends Node

var session_file_path = EDITOR_C.EDITOR_DIR + "/session"
var session_data = {}
#var pw = ('776fab579d752808b562943922a8f708ca769e15bb784fbccfa23329fee25c32' + OS.get_unique_id()).sha256_text()
var key = ("776fab579d752808b562943922a8f708ca769e15bb784fbccfa23329fee25c32" + OS.get_unique_id()).sha256_buffer()

# Data Fields:
# author
# user {id, email, subscription_ends_at, created_at, updated_at}
# last_file_path
# confirmed_updates
# tutorial_clicked

func _ready():
	setup()
	print("session: ", session_data)

func setup():
	var data = Utils.read_json_file(session_file_path, null, key)
	if data: 
		session_data = data
	else:
		session_data = {}
		
func get_value(key, default_val=null):
	if session_data.has(key):
		return session_data[key]
	else:
		return default_val
		
func set_value(key, value):
	session_data[key] = value
	
func save():
	Utils.write_json_file(session_file_path, session_data, null, key)

func save_value(key, value):
	set_value(key, value)
	save()
