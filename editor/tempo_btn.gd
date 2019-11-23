extends Control

signal tempo_changed

var tempo_meter_time = 0
var tempo_meter_started = false
var tempo_meter_vals = []

onready var tempo_val_input = get_node("VBoxC/HBoxC/SpinBox")
onready var btn = get_node("VBoxC/HBoxC/Button")

func _ready():
	set_process(true)

func _process(delta):
	if tempo_meter_started:
		tempo_meter_time += delta
		# 40 is min tempo, 1.5 in sec
		if tempo_meter_time > 1.5: # 6.0:
			tempo_meter_started = false
			
	

func _on_meter_btn_pressed():
	if not tempo_meter_started:
		tempo_meter_started = true
		tempo_meter_time = 0
		tempo_meter_vals = []
	elif tempo_meter_time > 0:
		var val = round(60.0/tempo_meter_time)
		tempo_meter_vals.append(val)
		if tempo_meter_vals.size() > 4: tempo_meter_vals.pop_front()
		print(tempo_meter_vals)

		var sum = 0.0
		for v in tempo_meter_vals: sum += v
		var tempo = round(sum/tempo_meter_vals.size())

		tempo_val_input.set_value(tempo)
		tempo_meter_time = 0


func _on_spin_box_changed(val):
	emit_signal("tempo_changed")

func set_disabled(val):
	#tempo_val_input.set_editable(!val)
	btn.set_disabled(val)

func get_tempo():
	return tempo_val_input.get_value()

func set_tempo(value):
	tempo_val_input.set_value(float(value))

