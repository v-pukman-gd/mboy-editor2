extends Control

#signal audio_load_success

var geditor = Geditor.new()
var wav_file_path
var ogg_file_path
var mp3_file_path
var active_note
var active_track
var window_size = 950
var is_playing = false
var is_follow_playing = false
var sample  #Sample.new()
var stream = AudioStreamOGGVorbis.new()

var audio_file_name = ""
var audio_load_thread= Thread.new()
var audio_loaded = false

var track_tempo = 130
var map_start_pos = 0
var map_info_was_saved = false
var pending_export = false #TODO: reset it after audio reload
var track_length
var track_speed

var waveform_length
var waveform_scale
var tempo_update_timeout = 0
var tempo_update_in_process = false

var ui_scale
var scale_ratio
var prev_scale_ratio

var bar_size
var bars_count
var sample_duration_in_sec
var quarter_time_in_sec

var window_scroll_size = 0
var d = 0
var pending_wscroll_update = false
var cursor_slider_pressed = false
var window_scroll_last_val = 0
var window_scroll_and_cursor_d = 0
var window_scroll_last_pos = 0

var tracks = []

onready var ui_node = get_node("UI")
onready var window_scroll = get_node("UI/MarginC/VBoxC/ScrollC")

onready var waveform_c = get_node("UI/MarginC/VBoxC/ScrollC/VBoxC/WaveformC")
onready var waveform_n = waveform_c.get_node("AudioWaveform")
#onready var waveform_node = window_scroll.get_node("VBoxC/WaveformC/Sprite")

#cursor
onready var cursor_c = get_node("UI/MarginC/VBoxC/ScrollC/VBoxC/WaveformC/CursorC")
onready var cursor_static = cursor_c.get_node("CursorStatic")
onready var cursor_playback = cursor_c.get_node("CursorPlayback")
onready var cursor_slider = cursor_c.get_node("HSlider")

#players
#onready var sample_player = get_node("Node")  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
onready var stream_player = get_node("AudioStreamPlayer")  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review

#dialogs
onready var dialog_c = get_node("UI/CenterC")
onready var load_audio_dialog = dialog_c.get_node("LoadAudioDialog")
onready var import_map_dialog = dialog_c.get_node("ImportMapDialog")
onready var export_map_dialog = dialog_c.get_node("ExportMapDialog")
onready var map_info = dialog_c.get_node("MapInfo")
onready var track_info = dialog_c.get_node("TrackInfo")
onready var notice_dialog = dialog_c.get_node("NoticeDialog")
onready var confirm_dialog = dialog_c.get_node("ConfirmDialog")
onready var note_markers_info_dialog = dialog_c.get_node("NoteMarkersInfoDialog")
onready var editor_info_dialog = dialog_c.get_node("EditorInfoDialog")

var opened_dialog 

#btn
onready var btn_c = get_node("UI/MarginC/VBoxC/CenterC/HBoxC")
onready var play_btn = btn_c.get_node("PlayBtn")
onready var add_track_btn = btn_c.get_node("AddTrackBtn")
onready var edit_track_btn = btn_c.get_node("EditTrackBtn")
onready var load_audio_btn = btn_c.get_node("LoadAudioBtn")
onready var scale_up_btn = btn_c.get_node("ZoomBtn/HBoxC/UpBtn")
onready var scale_down_btn = btn_c.get_node("ZoomBtn/HBoxC/DownBtn")
onready var export_btn = btn_c.get_node("ExportBtn")
onready var import_btn = btn_c.get_node("ImportBtn")
onready var tempo_btn = btn_c.get_node("TempoBtn")
onready var info_btn = btn_c.get_node("InfoBtn")
onready var set_start_input = btn_c.get_node("SetStartInput")

#btn2
onready var btn_c2 = get_node("UI/MarginC/VBoxC/CenterC2/HBoxC2")
onready var marker_manger_btn = btn_c2.get_node("MarkerManagerBtn")
onready var marker_btn = btn_c2.get_node("MarkerBtn")

onready var reset_btn = btn_c2.get_node("ResetBtn")
onready var exit_btn = btn_c2.get_node("ExitBtn")

#tracks
onready var tracks_c = get_node("UI/MarginC/VBoxC/ScrollC/VBoxC/TracksC")
var track_scn = preload("res://editor/track.tscn")

var editor_scn_path = "res://editor/editor.tscn"
var confirm_callback = ""
var editor_dir

func _ready():
	VisualServer.set_default_clear_color(EDITOR_C.BG_COLOR)
	get_tree().set_auto_accept_quit(false)
	
	editor_info_dialog.get_node("Text").bbcode_text = "[center]MBOY Editor v. %s[/center]" % EDITOR_C.VERSION

	set_process(true)
	set_process_input(true)
	cursor_slider.connect("value_changed", self, "_on_hslider_value_changed")
	window_scroll_size = window_scroll.get_minimum_size().x
	update_controls()
	setup_editor_dir()

	update_last_file_path(EDITOR_C.last_file_path)

	# disable shortcuts in popups
	for d in dialog_c.get_children():
		d.connect("about_to_show", self, "disable_inputs")
		d.connect("popup_hide", self, "enable_inputs")
	
	setup_markers()
	
	#TODO: remove this
	#Uncomment to Quick start file preload
	#load_audio("user://editor/audio_mock.ogg")

func _notification(what):
	# Confirm before exit
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		_on_exit_btn_pressed()

func disable_inputs(): set_process_input(false)
func enable_inputs(): set_process_input(true)

func update_last_file_path(file_path):
	EDITOR_C.last_file_path = file_path

func setup_editor_dir():
	# hint editor folder
	print("user data dir:", OS.get_user_data_dir())

	editor_dir = "user://editor"
	var dir = Directory.new()
	if not dir.open(editor_dir) == OK:
		dir.make_dir(editor_dir)

	print("editor_dir:", editor_dir)
	
func setup_markers(markers_data=null):
	EDITOR_NOTE_MARKER_C.load_markers(markers_data)
	marker_btn.setup()
	note_markers_info_dialog.setup()

func _process(delta):

	if pending_wscroll_update:
		window_scroll.set_h_scroll(window_scroll_size)
		pending_wscroll_update = false

	#update note buttons
	if active_note:
		marker_btn.set_disabled(EDITOR_NOTE_MARKER_C.markers.size() == 0)
	elif active_note == null:
		marker_btn.set_disabled(true)

	if active_track and active_track.is_active:
		edit_track_btn.set_disabled(false)
	elif active_track == null or not active_track.is_active:
		edit_track_btn.set_disabled(true)

	tracks_c.set_custom_minimum_size(Vector2(OS.get_window_size().x-200, 100))

	cursor_c.set_position(Vector2(cursor_c.get_position().x, window_scroll.get_v_scroll()))  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	if window_scroll_last_val != window_scroll.get_h_scroll():
		for t in tracks: t.move_label(window_scroll.get_h_scroll())

	# Waveorm update
	if tempo_update_timeout > 0:
		tempo_update_timeout -= delta
	elif tempo_update_timeout < 0:
		tempo_update_timeout = 0
		tempo_update_in_process = true
		
		var old_waveform_length = waveform_length
		
		var cursor_val = cursor_slider.get_value()
		var scroll_val = window_scroll.get_h_scroll()
		var dd = scroll_val - cursor_val
	
		set_params()
		redraw_map()
		
		var scale = waveform_length/old_waveform_length
		cursor_slider.set_value(cursor_slider.get_value()*scale)		
		window_scroll.set_h_scroll(cursor_slider.get_value()+dd)
		cursor_static.set_position(Vector2(cursor_slider.get_value(), cursor_static.get_position().y))  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
		if not is_playing:
			cursor_playback.set_position(cursor_static.get_position())
		
		tempo_update_in_process = false
		
	window_scroll_last_val = window_scroll.get_h_scroll()
	waveform_n.set_scroll(window_scroll_last_val)
	waveform_n.update()
	
	# TODO: bring back follow
	#if is_playing and is_follow_playing:
	#	if cursor_playback.get_position().x >= window_scroll.get_size().x/2.0:  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	#		window_scroll.set_h_scroll(cursor_playback.get_position().x-window_scroll.get_size().x/2.0)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review

func set_params():
	sample_duration_in_sec = stream.get_length() # sample.get_length()/float(sample.get_mix_rate())
	quarter_time_in_sec = 60.0/track_tempo
	bar_size = float(EDITOR_BAR_C.CELL_WIDTH * EDITOR_BAR_C.QUARTERS_COUNT * EDITOR_BAR_C.CELLS_IN_QUARTER_COUNT)

	track_speed = bar_size/(quarter_time_in_sec*EDITOR_BAR_C.QUARTERS_COUNT)
	track_length = round(track_speed * sample_duration_in_sec)
	bars_count = round(track_length / bar_size)

	waveform_scale = track_length/float(EDITOR_C.WAVEFORM_W)
	waveform_length = track_length

	print("w scale:", waveform_scale)
	print("t len:", track_length)
	print("w len:", waveform_length)

	cursor_playback.speed = track_speed

	waveform_c.set_size(Vector2(waveform_length, EDITOR_C.WAVEFORM_H))
	
	waveform_n.set_full_size(waveform_c.get_size())
	waveform_n.set_viewport_rect(Rect2(Vector2(),Vector2(window_scroll.get_size().x, EDITOR_C.WAVEFORM_H)))
	waveform_n.set_custom_minimum_size(waveform_c.get_size())

	cursor_slider.set_max(waveform_length)
	cursor_slider.set_custom_minimum_size(Vector2(waveform_length, 16))

	#scale reset
	ui_scale = 0
	scale_ratio = 1
	prev_scale_ratio = 1
	scale_to(0)

func load_waveform(stream):
	#print("load_waveform")
	#var img = geditor.waveform_image(sample, EDITOR_C.WAVEFORM_W, EDITOR_C.WAVEFORM_H)
	#var txt = ImageTexture.new()
	#txt.create_from_image(img)
	#waveform_node.set_texture(txt)
	waveform_n.set_stream(stream)


func update_cursor_length():
	var offset = 0
	for t in tracks: offset += t.get_custom_minimum_size().y
	cursor_static.set_length_offset(offset)
	cursor_playback.set_length_offset(offset)

func redraw_map():
	for t in tracks:
		t.setup(bars_count, true)

func play():
	if is_playing:
		is_playing = false
		stream_player.stop()
		cursor_playback.stop()
		cursor_playback.set_position(cursor_static.get_position())  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	else:
		is_playing = true
		unset_active_note()
		unset_active_track()
		var t = cursor_slider.get_value() / track_speed
		t = t / scale_ratio
		stream_player.play(t)
		cursor_playback.set_position(cursor_static.get_position())
		cursor_playback.start()

	play_btn.set_playing(is_playing)

func cursor_focus():
	#if cursor_playback.get_position().x - window_scroll.get_h_scroll() < 0:  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	#	window_scroll.set_h_scroll(cursor_playback.get_position().x)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	if is_playing:
		play()
	
	
	#print("cursor_playback.get_position().x:", cursor_playback.get_position().x)
	#print("slider value", cursor_slider.get_value())
	#window_scroll.set_h_scroll(cursor_playback.get_position().x-EDITOR_C.CURSOR_FOCUS_OFFSET)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	# Use slider value 
	#window_scroll.set_h_scroll(cursor_slider.get_value()-EDITOR_C.CURSOR_FOCUS_OFFSET)
	window_scroll.set_h_scroll(cursor_static.get_position().x-EDITOR_C.CURSOR_FOCUS_OFFSET)

func scale_to(dir):
	print("****** scale_to ******")
	var value = dir * (waveform_scale/10.0) #0.5
	ui_scale += value
	var curr_scale = waveform_scale + ui_scale
	scale_ratio = curr_scale/waveform_scale
	if scale_ratio <= 0:
		scale_ratio = 0.1
		ui_scale -= value
		return

#	if scale_ratio == 0.1:
#		if dir > 0:
#			scale_ratio = 0.5
#	else:
#		scale_ratio += dir*0.5
#
#	if scale_ratio <= 0:
#		scale_ratio = 0.1

#	scale_ratio += dir*0.1
#	if scale_ratio <= 0.1:
#		scale_ratio = 0.1
#		return
	
	var scale_d = scale_ratio/prev_scale_ratio
		
	print("scale to:", dir)
	print("scale_ratio:", scale_ratio)
	print("scale_d:", scale_d)

	# because cursor inside of waveform now
	# need to update cursor before waveform
	var cursor_val = cursor_slider.get_value()
	var scroll_val = window_scroll.get_h_scroll()
	d = scroll_val - cursor_val

	cursor_slider.set_max(waveform_length*scale_ratio)
	cursor_slider.set_custom_minimum_size(Vector2(waveform_length*scale_ratio, 256))
	cursor_slider.set_value(cursor_val*scale_d)

	var scaled_size = Vector2(waveform_length*scale_ratio, EDITOR_C.WAVEFORM_H)

	waveform_c.set_custom_minimum_size(scaled_size)
	waveform_c.set_size(scaled_size)

	waveform_n.set_custom_minimum_size(scaled_size)
	waveform_n.set_size(scaled_size)

	waveform_n.set_full_size(scaled_size)
	waveform_n.set_scale_ratio(scale_ratio)

	cursor_playback.speed_scale = scale_ratio

	window_scroll.set_h_scroll(cursor_slider.get_value()+d)

	#map
	for t in tracks: t.update_scale(scale_ratio)

	prev_scale_ratio = scale_ratio

	print("scale updated!")


func _on_scale_up_btn_pressed():
	scale_to(1)

func _on_scale_down_btn_pressed():
	scale_to(-1)

func _on_hslider_value_changed( value ):
	print("slider val changed:", value)
	if tempo_update_in_process:
		return

	cursor_static.set_position(Vector2(value, cursor_static.get_position().y))  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	cursor_playback.set_position(Vector2(value, cursor_playback.get_position().y))  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review

	
	if is_playing:
		var t = cursor_slider.get_value() / track_speed
		t = t / scale_ratio
		stream_player.play(t)
		#cursor_playback.start()

func _on_play_btn_pressed():
	play()

func _input(e):
	if not audio_loaded: return

	if e.is_action_pressed("editor_play"):
		is_follow_playing = false
		play_btn.btn.grab_focus()
	elif e.is_action_pressed("editor_follow_play"):
		if not is_playing:
			is_follow_playing = true
			play_btn.btn.grab_focus()
			play()
	elif e.is_action_pressed("editor_cursor_focus"):
		cursor_focus()
	elif e.is_action_pressed("editor_scale_up"):
		scale_up_btn.grab_focus()
		scale_to(1)
	elif e.is_action_pressed("editor_scale_down"):
		scale_down_btn.grab_focus()
		scale_to(-1)
	elif e.is_action_pressed("editor_sinfo"):
		print("window_scroll.get_h_scroll():", window_scroll.get_h_scroll())
		print("cursor_slider.get_value():", cursor_slider.get_value())


# EXPORT

func _on_export_btn_pressed():
	if not map_info_was_saved:
		popup_dialog(map_info)
		#map_info.popup()
		pending_export = true
	else:
		export_map_dialog.set_current_path(EDITOR_C.last_file_path)
		export_map_dialog.set_current_file("")
		popup_dialog(export_map_dialog)
		#export_map_dialog.popup()
		#if export_map_dialog.get_current_file() == "":
		#	export_map_dialog.set_current_file(audio_file_name)
		#export_map_dialog.set_current_dir(export_map_dialog.get_current_dir())

func _on_map_info_saved():
	map_info_was_saved = true
	if pending_export:
		export_map_dialog.set_current_path(EDITOR_C.last_file_path)
		export_map_dialog.set_current_file("")
		popup_dialog(export_map_dialog)
		#export_map_dialog.popup()
		#if export_map_dialog.get_current_file() == "":
		#	export_map_dialog.set_current_file(audio_file_name)

func _on_export_map_file_selected(file_path):
	export_data(file_path)

func _on_info_btn_pressed():
	popup_dialog(map_info)

func get_curr_date():
	var today = OS.get_date()
	return ("%s-%02d-%02d" % [today.year,today.month, today.day])

func export_data(file_path):
	var tracks_data = []
	for t in tracks: tracks_data.append(t.get_data())
	
	var markers_data = EDITOR_NOTE_MARKER_C.get_markers_data()
	
	var data = {
		editor = "music_boy_editor_v"+str(EDITOR_C.VERSION),
		audio = map_info.audio_info,
		author = map_info.author,
		date = get_curr_date(),
		tempo = track_tempo,
		start_pos = map_start_pos * EDITOR_BAR_C.CELL_EXPORT_SCALE,
		tracks = tracks_data,
		markers = markers_data
	}

	Utils.write_json_file(file_path, data)
	update_last_file_path(file_path)
	print("data exported")


# IMPORT

func _on_import_btn_pressed():
	import_map_dialog.set_current_path(EDITOR_C.last_file_path)
	import_map_dialog.set_current_file("")
	popup_dialog(import_map_dialog)

func _on_import_map_file_selected(file_path):
	import_data(file_path)

func import_data(file_path):
	var data = Utils.read_json_file(file_path)
	if not data: return

	#update editor
	track_tempo = int(data.tempo)
	tempo_btn.set_tempo(track_tempo)

	map_start_pos = int(int(data.start_pos)/EDITOR_BAR_C.CELL_EXPORT_SCALE)
	set_start_input.input.set_value(map_start_pos)

	map_info.set_data(data.author, data.audio)
	map_info_was_saved = false
	pending_export = false

	clear_tracks()
	set_params()
	scale_to(0)
		
	# markers
	var markers_data = null
	if data.has("markers"): 
		markers_data = data.markers
	setup_markers(markers_data)
	
	# tracks
	var y = EDITOR_BAR_C.CELL_HEIGHT + EDITOR_C.TRACK_DISTANCE
	for track_data in data.tracks:
		var t = track_scn.instance()
		t.set_data(track_data)
		t.set_position(Vector2(0, y))  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
		t.set_start_position(map_start_pos)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
		tracks_c.add_child(t)
		tracks.append(t)
		y += t.get_height()

	update_cursor_length()

	update_last_file_path(file_path)
	print("data imported")
	
	
# LOAD AUDIO
func _on_load_audio_btn_pressed():
	load_audio_dialog.set_current_path(EDITOR_C.last_file_path)
	load_audio_dialog.set_current_file("")
	popup_dialog(load_audio_dialog)

func _on_load_audio_dialog_file_selected(file_path):
	audio_load_thread.start(self, "load_audio", file_path)

func enable_load_audio(enabled):
	if enabled:
		load_audio_btn.label.set_text("te_load_audio")
		load_audio_btn.set_disabled(false)
	else:
		load_audio_btn.label.set_text("te_loading")
		load_audio_btn.set_disabled(true)

func update_load_audio(text):
	if load_audio_btn.btn.is_disabled():
		load_audio_btn.label.set_text(text)

func copy_audio(input_file_path):
	print("copy started")
	var file_name = input_file_path.get_file()
	var file_format = str(file_name.get_extension()).to_lower()
	var dir = Directory.new()
	#store original name
	audio_file_name = file_name.substr(0, file_name.find_last('.'))

	wav_file_path = editor_dir + "/" + "audio" + ".wav"
	ogg_file_path = editor_dir + "/" + "audio" + ".ogg"
	mp3_file_path = editor_dir + "/" + "audio" + ".mp3"
	#var res

	# we need ogg and wav
	# we support ogg, mp3, wav on input
	if file_format == "ogg":
		#ogg_file_path = input_file_path
		dir.copy(input_file_path, ogg_file_path)
		#res = geditor.ogg_to_wav(ogg_file_path, wav_file_path)
		#if res == 0:
		#	show_notice("te_ogg_to_wav_failed")
		#	return false
#	elif file_format == "mp3":
#		dir.copy(input_file_path, mp3_file_path)
#		res = geditor.mp3_to_wav(mp3_file_path, wav_file_path)
#		if res < 0:
#			show_notice("te_mp3_to_wav_failed")
#			return false
#		res = geditor.wav_to_ogg(wav_file_path, ogg_file_path)
#		if res == 0:
#			show_notice("te_wav_to_ogg_failed")
#			return false
#	elif file_format == "wav":
#		dir.copy(input_file_path, wav_file_path)
#		#wav_file_path = input_file_path
#		res = geditor.wav_to_ogg(wav_file_path, ogg_file_path)
#		if res == 0:
#			show_notice("te_wav_to_ogg_failed")
#			return false
	else:
		show_notice(str(file_format) +  tr("te_format_is_not_supported"))
		return false

	print("copy finished")
	return true

func check_audio():
	var checker = File.new()
	#if not checker.file_exists(wav_file_path):
	#	show_notice(wav_file_path + tr("te_is_not_found"))
	#	return false
	if not checker.file_exists(ogg_file_path):
		show_notice(ogg_file_path + tr("te_is_not_found"))
		return false
	return true

func is_audio_loaded(audio_data):
	if audio_data == null:
		show_notice("te_audio_is_not_loaded")
		audio_load_thread.wait_to_finish()
		enable_load_audio(true)
		return false
	else:
		return true

func load_ogg(path):
	var ogg_file = File.new()
	ogg_file.open(path, File.READ)
	var bytes = ogg_file.get_buffer(ogg_file.get_len())
	var stream = AudioStreamOGGVorbis.new()
	stream.data = bytes
	ogg_file.close()
	return stream

func load_audio(input_file_path):
	print("loading started " , input_file_path)
	enable_load_audio(false)

	update_load_audio(tr("te_loading_1_3"))

	var is_copied = copy_audio(input_file_path)
	if not is_copied:
		audio_load_thread.wait_to_finish()
		enable_load_audio(true)
		return

	if not check_audio():
		audio_load_thread.wait_to_finish()
		enable_load_audio(true)
		return

	update_load_audio(tr("te_loading_2_3"))

	stream = load_ogg(ogg_file_path)
	print("FILE:", ogg_file_path, stream)
	if not is_audio_loaded(stream): return
	stream_player.set_stream(stream)
	update_load_audio(tr("te_loading_3_3"))

	load_waveform(stream)
	set_params()

	map_info.setup(audio_file_name, geditor.ogg_comments(ogg_file_path))

	enable_load_audio(true)
	audio_loaded = true
	update_controls()

	audio_load_thread.wait_to_finish()
	update_last_file_path(input_file_path)

	print("audio loaded")

func update_controls():
	if audio_loaded:
		load_audio_btn.set_disabled(true) # restart editor to load audio again

		play_btn.set_disabled(false)
		add_track_btn.set_disabled(false)
		scale_up_btn.set_disabled(false)
		scale_down_btn.set_disabled(false)
		export_btn.set_disabled(false)
		tempo_btn.set_disabled(false)
		import_btn.set_disabled(false)
		set_start_input.input.set_editable(true)
		info_btn.set_disabled(false)
		reset_btn.set_disabled(false)
		marker_manger_btn.set_disabled(false)

		window_scroll.show()
	elif not audio_loaded:
		play_btn.set_disabled(true)
		add_track_btn.set_disabled(true)
		scale_up_btn.set_disabled(true)
		scale_down_btn.set_disabled(true)
		export_btn.set_disabled(true)
		tempo_btn.set_disabled(true)
		import_btn.set_disabled(true)
		set_start_input.input.set_editable(false)
		info_btn.set_disabled(true)
		reset_btn.set_disabled(true)
		marker_manger_btn.set_disabled(true)
		

		window_scroll.hide()

func _on_tempo_changed():
	print("_on_tempo_changed:")
	
	if track_tempo != tempo_btn.get_tempo():
		track_tempo = tempo_btn.get_tempo()
		tempo_update_timeout = 1.0
		
		print("tempo updated to", track_tempo)

func _on_ScrollC_minimum_size_changed():
	var dd =  cursor_slider.get_value() - window_scroll.get_h_scroll()
	if dd > window_size and not pending_wscroll_update:
		window_scroll_size = window_scroll.get_h_scroll() + dd + d
		pending_wscroll_update = true

func _on_ScrollC_resized():
	#print("_on_ScrollC_resized:", window_scroll.get_size())
	# Update waveform viewport size and position
	waveform_n.set_viewport_rect(Rect2(Vector2(window_scroll_last_val, 0),Vector2(window_scroll.get_size().x, EDITOR_C.WAVEFORM_H)))
	


# ACTIVE NOTE
func set_active_note(note):
	if active_note != null: active_note.set_active(false)
	active_note = note
	active_note.set_active(true)
	set_active_track(note.bar.track)

func unset_active_note():
	if active_note != null: active_note.set_active(false)
	active_note = null

#func add_note_marker(marker):
#	if active_note != null: active_note.add_markers([marker])

#func _on_mark_accent_btn_pressed(): add_note_marker(EDITOR_NOTE_MARKER_C.ACCENT)
#func _on_mark_epic_btn_pressed(): add_note_marker(EDITOR_NOTE_MARKER_C.EPIC)
#func _on_mark_extended_btn_pressed(): add_note_marker(EDITOR_NOTE_MARKER_C.EXTENDED)
#func _on_mark_mix_btn_pressed(): add_note_marker(EDITOR_NOTE_MARKER_C.MIX)
#func _on_mark_autoplay_btn_pressed(): add_note_marker(EDITOR_NOTE_MARKER_C.AUTOPLAY)

func _on_note_marker_btn_pressed(marker):
	if active_note != null: active_note.add_markers([marker])

func _on_start_pos_input_changed(val):
	map_start_pos = val
	for t in tracks:
		t.set_start_position(map_start_pos)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review



func _on_stream_player_finished():
	if is_playing: play()


# ADD TRACK
func _on_add_track_btn_pressed():
	track_info.setup(null)
	popup_dialog(track_info)
	#track_info.popup()

func _on_track_info_saved():
	if track_info.track:
		update_track(track_info.track)
	else:
		add_track()

func _on_edit_track_btn_pressed():
	track_info.setup(active_track)
	popup_dialog(track_info)
	#track_info.popup()


func add_track():
	var t = track_scn.instance()
	t.set_info(track_info)
	t.setup(bars_count)
	t.set_position(Vector2(0, tracks.size()+1* (EDITOR_BAR_C.CELL_HEIGHT + EDITOR_C.TRACK_DISTANCE)))  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	t.set_start_position(map_start_pos)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	tracks_c.add_child(t)
	tracks.append(t)
	set_active_track(t)
	update_cursor_length()
	scale_to(0)

func destroy_track(track):
	if active_track == track: active_track = null
	tracks_c.remove_child(track)
	tracks.erase(track)
	update_cursor_length()


func clear_tracks():
	for t in tracks: destroy_track(t)

func update_track(track):
	if track_info.pending_destroy:
		destroy_track(track)
	else:
		track.set_info(track_info)

func set_active_track(track):
	print("SET ACTIVE:", track)
	if active_track != null: active_track.set_active(false)
	active_track = track
	active_track.set_active(true)


func unset_active_track():
	if active_track != null: active_track.set_active(false)
	active_track = null


func grab_cursor_slider_focus(e):
	#TODO: fix later
	#print("FIXME: grab_cursor_slider_focus", e)
	return
	if e.global_pos.y <= cursor_c.get_global_position().y+cursor_c.get_size().y+10.0:  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
		if (e is InputEventMouseButton and e.button_index == BUTTON_LEFT):  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
			cursor_slider_pressed = e.pressed
			if cursor_slider_pressed:
				cursor_slider.set_value(e.global_pos.x-cursor_slider.get_global_position().x)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review

		if e is InputEventMouseMotion:  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
			if cursor_slider_pressed:
				 cursor_slider.set_value(e.global_pos.x-cursor_slider.get_global_position().x)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review

		return true
	return false

func show_notice(text):
	notice_dialog.get_node("Text").set_text(text)
	popup_dialog(notice_dialog)

func popup_dialog(dialog):
	dialog.popup()
	var x = int(ui_node.get_size().x/2.0 - dialog.get_size().x/2.0)
	dialog.set_position(Vector2(x,0)) 
  
func _on_editor_minimum_size_changed():
	pass
	#var size = get_viewport().get_rect().size
	#ui_node.set_size(size)
	#print("*******")
	#print(get_viewport().get_rect().size)
	#print(get_node("UI/MarginC/VBoxC/ScrollC").get_rect().size)


func _on_exit_btn_pressed():
	popup_confirm(tr("te_exit_confirm"), "exit_editor")

func exit_editor():
	if audio_load_thread.is_active(): audio_load_thread.wait_to_finish()
	#if has_node("/root/SceneLoader"):
	#	get_node("/root/SceneLoader").goto_scene("res://ui/start_ui.tscn")
	#else:
	#	get_tree().quit()
	get_tree().quit()

func _on_reset_btn_pressed():
	popup_confirm(tr("te_reset_confirm"), "reset_editor")

func reset_editor():
	if audio_load_thread.is_active(): audio_load_thread.wait_to_finish()
	#if has_node("/root/SceneLoader"):
	#	get_node("/root/SceneLoader").goto_scene("res://editor/editor.tscn")
	#else:
	#	get_tree().change_scene(editor_scn_path)
	get_tree().change_scene(editor_scn_path)

func popup_confirm(text, callback):
	confirm_dialog.get_node("Text").set_bbcode("[center]"+str(text)+"[/center]")
	confirm_callback = callback
	popup_dialog(confirm_dialog)


func _on_action_confirmed():
	var callback = str(confirm_callback)
	confirm_callback = ""
	if callback != "":
		call(callback)


class Geditor:
	func waveform_image():
		pass
	func ogg_comments(file):
		return ""

func _on_ScrollC_scroll_started():
	pass

func _on_marker_manager_btn_pressed():
	popup_dialog(note_markers_info_dialog)

func _on_markers_updated():
	marker_btn.setup()

func _on_editor_info_btn_pressed():
	popup_dialog(editor_info_dialog)
