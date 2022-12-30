extends ConfirmationDialog

signal logged_in

onready var email_input = $VBoxC/Email
onready var password_input = $VBoxC/Password
onready var error_label = $VBoxC/ErrorLabel
onready var http_request = $HTTPRequest

func _ready():
	pass
	#show()

func _on_confirmed():
	clear_error()
	
	if email_input.text == "" or password_input.text == "":
		keep_opened()
		show_error(tr("te_editor_required_fields"))
		return
	
	#TODO: add editor version to header
	var body = JSON.print({"user": {"email": email_input.text, "password": password_input.text }})
	http_request.request(EDITOR_C.API.login, ["User-Agent: MBOYEditor", "Content-Type: application/json"], true, HTTPClient.METHOD_POST, body)
	keep_opened()
	
func keep_opened():
	var pos = get_position()
	popup()
	set_position(pos)
	
func _on_popup_hide():
	clear_error()
	
func clear_error():
	error_label.text = ""
	
func show_error(text):
	error_label.text = text

# OK = 0
func _on_request_completed(result, response_code, headers, body):
	#print(result, " ", response_code, headers)
	
	if result != HTTPRequest.RESULT_SUCCESS:
		show_error(tr("te_request_failed"))
		return
	
	var json = JSON.parse(body.get_string_from_utf8())
	if json.error != OK:
		show_error(tr("te_parse_result_failed"))
		return
		
	var response = json.result
	print(response)
			
	if response.has("error"):
		show_error(response.error)
	elif response.has("id"):
		print("request success:")
		
		var auth_header = null
		for h in headers:
			if "Authorization:" in str(h):
				auth_header = h
				break
		
		emit_signal("logged_in", response, auth_header)
		password_input.text = ""
		hide()
	else:
		show_error(tr("te_response_no_data"))
