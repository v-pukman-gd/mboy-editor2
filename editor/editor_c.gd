extends Node

# fix load map error
const VERSION = "1.4.1"

const WAVEFORM_H = 256
const WAVEFORM_W = 1255 #4096

const BG_COLOR = Color("4c4c4c")

const TRACK_TEMPO_DEFAULT = 120
const TRACK_TEMPO_MAX = 900

const TRACK_DISTANCE = 50

const CURSOR_FOCUS_OFFSET = 150

#var last_load_audio_path = "//"
#var last_import_map_path = "//"
#var last_export_map_path = "//"
var last_file_path = "//"

const GENRES = [
	"Other",
	"African",
  "Arabic",
	"Asian",
	"Avantgarde",
	"Blues",
	"Caribbean",
	"Classical",
	"Comedy",
	"Country",
	"EasyListening",
	"Electronic",
	"Folk",
	"HipHop",
	"Jazz",
	"Latin",
	"Pop",
	"RnB",
	"Rock",
	"Soundtrack",
]

