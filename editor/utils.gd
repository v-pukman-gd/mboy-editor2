extends Node

func read_json_file(file_path):
	var file = File.new()
	if not file.file_exists(file_path):
		print("File not found!", file_path)
		return

	if file.open(file_path, File.READ) != OK:
		print("File openning error!", file_path)
		return

	if not file.get_as_text():
		print("File is empty!", file_path)
		return

	var json = JSON.parse(file.get_as_text())
	if json.error != OK:
		print("File JSON parse error!", file_path)
		return

	return json.result
	
func write_json_file(file_path, data):
	var file = File.new()
	if file.open(file_path, File.WRITE) != OK:
		print("File cant be opened to write", file_path)
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
