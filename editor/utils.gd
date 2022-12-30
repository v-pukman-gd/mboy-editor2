extends Node

# to generate key for open_encrypted case:
# "string_key".sha256_buffer()
# https://github.com/godotengine/godot/blob/58ca3031419cacb35c530cebe68e87a4c27dde06/core/io/file_access_encrypted.cpp#open_and_parse_password
func read_json_file(file_path, password=null, key=null):
	var file = File.new()
	if not file.file_exists(file_path):
		print("File not found!", file_path)
		return
	
	var result
	if password != null:
		result = file.open_encrypted_with_pass(file_path, File.READ, password)
	elif key != null:
		result = file.open_encrypted(file_path, File.READ, key)
	else:
		result = file.open(file_path, File.READ)
	
	if result != OK:
		print("File openning error!", file_path, " result: ", result)
		return

	if not file.get_as_text():
		print("File is empty!", file_path)
		return

	var json = JSON.parse(file.get_as_text())
	if json.error != OK:
		print("File JSON parse error!", file_path)
		return

	return json.result
	
func write_json_file(file_path, data, password=null, key=null):
	var file = File.new()
	
	var result
	if password != null:
		result = file.open_encrypted_with_pass(file_path, File.WRITE, str(password))
	elif key != null:
		result = file.open_encrypted(file_path, File.WRITE, key)
	else:
		result = file.open(file_path, File.WRITE)
	
	if result != OK:
		print("File cant be opened to write", file_path, " result: ", result)
		return
		
	file.store_line(JSON.print(data))
	file.close()

#TODO: in new Godot can be replaced by Time.get_datetime_dict_from_datetime_string
func parse_date(iso_date):
	var date = iso_date.split("T")[0].split("-")
	var time = iso_date.split("T")[1].trim_suffix("Z").split(":")

	return {
		year = date[0],
		month = date[1],
		day = date[2],
		hour = time[0],
		minute = time[1],
		second = time[2],
	}
	
func time_left(iso_date):
	var ends_at = parse_date(iso_date)
	var now = OS.get_datetime(true)

	var diff = OS.get_unix_time_from_datetime(ends_at) - OS.get_unix_time_from_datetime(now)
	#print("diff", diff)
	#print("diff minutes", diff/60.0)
	return diff
