extends AcceptDialog

func _ready():
	#show()
	$TabContainer/About.bbcode_text = "[center]MBOY Editor v. %s\n Created by %s\n [url=%s]%s[/url] \n\n %s\n [/center]" % [EDITOR_C.VERSION, EDITOR_C.AUTHOR, EDITOR_C.SITE_URL, EDITOR_C.SITE_URL, pro_version_info()]

func _on_About_meta_clicked(meta):
	if meta == EDITOR_C.SITE_URL:
		OS.shell_open(EDITOR_C.SITE_URL)
	elif meta == EDITOR_C.PRO_URL:
		OS.shell_open(EDITOR_C.PRO_URL)

func pro_version_info():	
	return "Free version is limited to %s tracks \n [url=%s]Buy Pro[/url] version to have unlimited tracks" % [EDITOR_C.MAX_TRACKS_FREE, EDITOR_C.PRO_URL]
	
