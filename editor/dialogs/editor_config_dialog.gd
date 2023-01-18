extends AcceptDialog

const MAILTO = "mailto:%s?subject=MBOYEditor&body=Hi Vic!\n" % EDITOR_C.SUPPORT_EMAIL

func _ready():
	#show()
	$TabContainer/Support.bbcode_text = "[center]MBOY Editor v. %s\n Created by %s\n [url=%s]%s[/url] \n\n %s\n [/center]" % [EDITOR_C.VERSION, EDITOR_C.AUTHOR, EDITOR_C.SITE_URL, EDITOR_C.SITE_URL, pro_version_info()]

func _on_Support_meta_clicked(meta):
	if meta == EDITOR_C.SITE_URL:
		OS.shell_open(EDITOR_C.SITE_URL)
	elif meta == EDITOR_C.PRO_URL:
		OS.shell_open(EDITOR_C.PRO_URL)
	elif meta == MAILTO:
		OS.shell_open(MAILTO)

func pro_version_info():
	return "Free version is limited to %s tracks \n [url=%s]Buy Pro[/url] version to have unlimited tracks \n\n Do you have a question / feedback? \n [url=%s]Send email[/url]" % [EDITOR_C.MAX_TRACKS_FREE, EDITOR_C.PRO_URL, MAILTO]
	
