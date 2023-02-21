extends Node3D

@onready var idle := $idle as AudioStreamPlayer
@onready var low := $low as AudioStreamPlayer
@onready var med := $med as AudioStreamPlayer
@onready var high := $high as AudioStreamPlayer

@onready var players: Array[AudioStreamPlayer] = [idle, low, med, high]
@export var db_curves: Array[Curve]
@export var pitch_curves: Array[Curve]

@export var car: Car

var n: float = 0

func _ready() -> void:
	await get_tree().physics_frame
	for p in players: p.play()

func _process(d: float):
	var r := car.rpm()
	if car.engine_force > 0.1 and car.is_on_ground():
		n = move_toward(n, clampf(r / 700.0, 0, 1), 1 * d)
		for i in 4:
			curve_player(i)
	else:
		n = move_toward(n, 0, 1 * d)
		curve_player(0)
		for i in 4:
			curve_player(i)

func curve_player(i: int) -> void:
	players[i].volume_db = db_curves[i].sample_baked(n) - 50
	players[i].pitch_scale = (pitch_curves[i].sample_baked(n) * 2) + .001
