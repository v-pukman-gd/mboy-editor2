extends Node

signal update_available
#var thread

func _ready():
	#thread = Thread.new()
	#thread.start(self, "check_update")
	check_update()
	
func check_update():
	$HTTPRequest.request(
		EDITOR_C.API.versions, 
		EDITOR_C.HTTP_HEADERS, 
		true, 
		HTTPClient.METHOD_GET
	)
	
#func _exit_tree():
#	thread.wait_to_finish()

func _on_request_completed(result, response_code, headers, body):
	#print(result, " ", response_code, " ", headers, " ", body.get_string_from_utf8())
	#thread.wait_to_finish()
	
	if result != HTTPRequest.RESULT_SUCCESS:
		print("update_checker: request failed")
		return
	
	if response_code != 200:
		print("update_checker: failed with code:", response_code)
		return
		
	var json = JSON.parse(body.get_string_from_utf8())
	if json.error != OK:
		print("update_checker: parse failed")
		return
		
	var response = json.result
	
	if response and response.has("current"):
		if response.current and response.current.has("number"):
			var new_version_info = {
				"number": response.current.number,
				"download_link": response.current.download_link,
				"changes": response.current.changes,
			}
					
			if str(new_version_info.number) != str(EDITOR_C.VERSION):
				emit_signal("update_available", new_version_info)
