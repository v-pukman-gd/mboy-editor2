extends Node

const VERSION = "2.1.1"
const AUTHOR = "Victor Pukman"
#const SITE_URL = "https://mboy-games.com"
const SITE_URL = "http://localhost:5000"
const PRO_URL = SITE_URL + "/?header=buy-pro"
const API_URL = SITE_URL + "/api/v1"
const API = {
	"login": API_URL + "/login"
}


const FORMAT_VERSION = "2.0"

const WAVEFORM_H = 128
const WAVEFORM_W = 1280 #4096

const BG_COLOR = Color("4d4d4d") #grey

const TRACK_TEMPO_DEFAULT = 120
const TRACK_TEMPO_MAX = 900

const TRACK_DISTANCE = 50

const CURSOR_FOCUS_OFFSET = 20

const MAX_TRACKS_FREE = 3
const MAX_TRACKS_PRO = 1000
var MAX_TRACKS = MAX_TRACKS_FREE


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

