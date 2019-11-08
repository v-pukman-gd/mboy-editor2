extends ConfirmationDialog

signal map_info_saved

#const AUDIO_FIELD_NAMES = [
#	"TITLE",
#	"VERSION",
#	"ALBUM",
#	"TRACKNUMBER",
#	"ARTIST",
#	"PERFORMER",
#	"COPYRIGHT",
#	"LICENSE",
#	"ORGANISATION",
#	"DESCRIPTION",
#	"SUBGENRE",
#	"DATE",
#	"LOCATION",
#	"CONTACT",
#	"ISRC",
#	"COMMENTS"
#]

const AUDIO_FIELD_NAMES = [
	"TITLE",
	"ALBUM",
	"ARTIST",
	"GENRE",
	"SUBGENRE",
	"COMMENTS",
	"DATE"
]

var audio_info = {}
var audio_file_name = ""
var author
var session_file_path = "user://editor/session"
var session_data = {}

onready var audio_c = get_node("VBoxC/AudioInfoC")
onready var map_c = get_node("VBoxC/MapInfoC")

onready var author_input = map_c.get_node("Author")

#audio
onready var artist_input = audio_c.get_node("Artist")
onready var title_input = audio_c.get_node("Title")
onready var album_input = audio_c.get_node("Album")
onready var genre_select = audio_c.get_node("GenreSelect")
onready var subgenre_input = audio_c.get_node("Subgenre")
onready var release_date_input = audio_c.get_node("ReleaseDate")
#onready var copyright_input = audio_c.get_node("Copyright")
#onready var license_input = audio_c.get_node("License")
onready var download_link = audio_c.get_node("DownloadLink")
onready var comments_input = audio_c.get_node("Comments")

func setup(audio_file_name, audio_comments):
	self.audio_file_name = audio_file_name
	init_genres()
	init_audio_inputs(audio_comments)
	init_map_inputs()

func init_genres():
	for i in range(0, EDITOR_C.GENRES.size()):
		genre_select.add_item(EDITOR_C.GENRES[i], i)

func init_audio_inputs(audio_comments):
	parse_audio_comments(audio_comments)
	if title_input.get_text() == "":
		title_input.set_text(audio_file_name)

func init_map_inputs():
	var file = File.new()
	if not file.file_exists(session_file_path):
		return

	if file.open(session_file_path, File.READ) != 0:
		return

	session_data.parse_json(file.get_as_text())
	author = str(session_data.author)
	author_input.set_text(author)

func set_audio_inputs_from(data):
	artist_input.set_text(data["artist"])
	title_input.set_text(data["title"])
	album_input.set_text(data["album"])
	subgenre_input.set_text(data["subgenre"])
	release_date_input.set_text(data["date"])
	if data.has("download_link"):
		download_link.set_text(data["download_link"])
	comments_input.set_text(data["comments"])

	if title_input.get_text() == "":
		title_input.set_text(audio_file_name)

	var i = 0
	var genre_val = str(data["genre"])
	for g in EDITOR_C.GENRES:
		if genre_val == g:
			break
		else:
			i += 1
	genre_select.select(i)

#prefile some fields from audio file info
func parse_audio_comments(audio_comments):
	for c in audio_comments:
		for f in AUDIO_FIELD_NAMES:
			if c.to_upper().find(str(f)+"=") != -1 and c.split("=").size() > 1:
				var val = c.split("=")[1]
				var node_name = f.to_lower().capitalize()
				if audio_c.has_node(node_name):
					var n = audio_c.get_node(node_name)
					n.set_text(val)
				break



func apply_audio_inputs():
	audio_info["artist"] = artist_input.get_text()
	audio_info["title"] = title_input.get_text()
	audio_info["album"] = album_input.get_text()
	audio_info["subgenre"] = subgenre_input.get_text()
	audio_info["date"] = release_date_input.get_text()
	audio_info["download_link"] = download_link.get_text()
	audio_info["comments"] = comments_input.get_text()
	audio_info["genre"] = EDITOR_C.GENRES[genre_select.get_selected()]

func apply_map_inputs():
	author = author_input.get_text()

	var file = File.new()
	if file.open(session_file_path, File.WRITE) != 0:
		return

	session_data["author"] = author
	file.store_line(session_data.to_json())
	file.close()


func _on_map_info_confirmed():
	if author_input.get_text() == "" or title_input.get_text() == "" or download_link.get_text() == "":
		# not valid
		popup()
		return
	apply_map_inputs()
	apply_audio_inputs()
	emit_signal("map_info_saved")

func set_data(author_data, audio_data):
	author_input.set_text(str(author_data))
	set_audio_inputs_from(audio_data)
	apply_map_inputs()
	apply_audio_inputs()


