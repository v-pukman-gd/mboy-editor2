extends AcceptDialog

func _ready():
	#show()
	$TabContainer/About.bbcode_text = "[center]MBOY Editor v. %s\n %s\n Created by %s\n [url=%s]%s[/url][/center]" % [EDITOR_C.VERSION, pricing_plan_info(), EDITOR_C.AUTHOR, EDITOR_C.SITE_URL, EDITOR_C.SITE_URL]

func _on_About_meta_clicked(meta):
	if meta == EDITOR_C.SITE_URL:
		OS.shell_open(EDITOR_C.SITE_URL)

func pricing_plan_info():
	#if EDITOR_C.PRICING_PLAN == "free":
	return "FREE VERSION (limited to %s tracks)" % EDITOR_C.MAX_TRACKS
	#else:
	#	return ""
