extends Node3D

@onready var idle := $idle as AudioStreamPlayer
@onready var low := $low as AudioStreamPlayer
@onready var med := $med as AudioStreamPlayer
@onready var high := $high as AudioStreamPlayer

@onready var players: Array[AudioStreamPlayer] = [idle, low, med, high]
@export var db_curves: Array[Curve]
@export var pitch_curves: Array[Curve]

@export var car: Car

func _ready() -> void:
	await get_tree().physics_frame
	for p in players: p.play()

func _process(_d: float):
	var r := car.rpm()
	var n := clampf(r / 500.0, 0, 1)
#	var s := "with n: %.2f" % n
	for i in 4:
		players[i].volume_db = (db_curves[i].sample_baked(n) - 50)
		players[i].pitch_scale = (pitch_curves[i].sample_baked(n) * 2) + .001
#		s += " | %s's: %.2f (%.2f)" % [players[i].name, players[i].volume_db, players[i].pitch_scale]
		if n > .9:
			players[-1].pitch_scale = (car.rpm() / 600) + 1
#	print(s)

