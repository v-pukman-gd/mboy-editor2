extends ColorRect

var stream = preload("res://audio.ogg")
var preview
var loaded = false
#onready var _preview = $ColorRect

func _ready():
	var g = AudioStreamPreviewGenerator.new()
	g.connect("preview_updated", self, "_on_preview_updated")
	preview = g.generate_preview(stream)
	#print(preview.get_max(1,1.1))
	#self.connect("draw", self, "_draw_preview")
	set_process(true)
	update()
	
	
func _draw_preview():
	print("_draw_preview")
	
	#if not preview:
	#	return
		
	#var rect = get_rect()
	var size = get_size()
	print("audiow size:", size)
	var preview_len = float(preview.get_length())
	
	#var lines = Vector2()
	#draw_multiline()
	var lines = PoolVector2Array()
	lines.resize(size.x * 2)
	
	for i in range(0, size.x):
		var ofs = i * preview_len / size.x
		var ofs_n = (i+1) * preview_len / size.x
		var maxi = preview.get_max(ofs, ofs_n) * 0.5 + 0.5
		var mini = preview.get_min(ofs, ofs_n) * 0.5 + 0.5
		
		var idx = i
		#lines.insert(idx*2+0, Vector2(i+1, rect.position.y + mini * rect.size.y));
		#lines.insert(idx*2+1, Vector2(i+1, rect.position.y + maxi * rect.size.y));
		lines.insert(idx*2+0, Vector2(i+1, mini * size.y));
		lines.insert(idx*2+1, Vector2(i+1, maxi * size.y));
		
	#print(lines)
	#var colors = PoolColorArray()
	#colors.push_back(Color(0.75, 0.75, 0.75, 1))
	var color = Color(0.68, 1, 0.18, 1)
	
	draw_multiline(lines, color)
	#draw_line(Vector2(2,2), Vector2(30,30), color)
	
func _on_preview_updated(e):
	if not loaded:
		loaded = true
		_draw()
	update()
	#print("on preview updated", e)


func _draw():
	if loaded:
		_draw_preview()
