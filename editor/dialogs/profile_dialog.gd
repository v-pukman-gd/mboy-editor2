extends AcceptDialog

signal logout_user

onready var email_label = $VBoxC/EmailLabel
onready var pro_c = $VBoxC/HBoxC
onready var sub_c = $VBoxC/HBoxC2
onready var pro_btn = $VBoxC/ProBtn

func _ready():
	#show()
	pass
	
func setup(user):
	if !user:
		email_label.text = ""
		sub_c.get_node("DateLabel").text = ""
		return
		
	email_label.text = user.email
	var diff = -1
	if user.subscription_ends_at:
		diff = Utils.time_left(user.subscription_ends_at)		
	
	if diff > 0:
		pro_c.get_node("NoLabel").hide()
		pro_c.get_node("YesLabel").show()
		
		sub_c.show()
		var date = Utils.parse_date(user.subscription_ends_at)
		sub_c.get_node("DateLabel").text = "%s-%s-%s" % [date.day, date.month, date.year]
			
		if ((diff/3600.0)/24.0) <= 14:
			pro_btn.text = tr("te_extend_pro")
			pro_btn.show()
		else:
			pro_btn.text  = tr("te_buy_pro")
			pro_btn.hide() # return original name but don't show
	else:
		pro_c.get_node("NoLabel").show()
		pro_c.get_node("YesLabel").hide()
		
		sub_c.hide()
		
		pro_btn.text = tr("te_buy_pro")
		pro_btn.show()
		

func _on_logout_pressed():
	emit_signal("logout_user")
	hide()


func _on_pro_pressed():
	OS.shell_open(EDITOR_C.PRO_URL)
	hide()
