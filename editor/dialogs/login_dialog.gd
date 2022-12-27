extends ConfirmationDialog

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
		var pos = get_position()
		popup()
		set_position(pos)
		show_error(tr("te_editor_required_fields"))
		return
	
	var body = to_json({"user": {"email": email_input.text, "password": password_input.text }})
	http_request.request("http://localhost:5000/api/v1/login", ["User-Agent: MBOYEditor", "Content-Type: application/json"], false, HTTPClient.METHOD_POST, body)
	var pos = get_position()
	popup()
	set_position(pos)
	
func _on_popup_hide():
	clear_error()
	
func clear_error():
	error_label.text = ""
	
func show_error(text):
	error_label.text = text


func _on_request_completed(result, response_code, headers, body):
	print(result, " ", response_code, headers)
	
	var response = parse_json(body.get_string_from_utf8())
	print(response)
	if response["error"]:
		show_error(response.error)
