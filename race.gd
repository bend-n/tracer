extends Node3D

@export var car_scene: PackedScene
@export var track: TrackLoader
@export var splits: Control
@export var timer: Control
@onready var data := TrackSaveableData.new(track.checkpoints.size())
@onready var best_time_data := TrackSaveableData._load(saves % track.track.name)
var car: Node3D
var start_frame: int

const SaveLoad := preload("res://addons/@bendn/remap/private/SaveLoadUtils.gd")
const saves := "user://%s.trackdata"

signal created_car(car: Car)
signal finished

func _ready() -> void:
	car = car_scene.instantiate()
	car.set_script(load("res://classes/human_car.gd"))
	add_child(car)
	car.ball.freeze = true
	car.visible = false
	car.global_position = track.start_pos + Vector3.UP * 3.5
	car.set_deferred(&"rotation", track.start_rot + Vector3.UP * PI)
	await get_tree().process_frame
	car.global_position = car.global_position - (car.ball.global_transform.basis.z * 2) # bump forward a teensy bit
	car.visible = true
	created_car.emit(car)
	for i in len(track.checkpoints):
		track.checkpoints[i].collected.connect(collect.bind(i))

	track.finish.collected.connect(
		func passed_finish() -> void:
			for t in data.checkpoints: # no any() function on packedfloat32
				if t < 0:
					return
			collect(-1)
			finished.emit()
			if not best_time_data or data.time < best_time_data.time:
				SaveLoad.save(saves % track.track.name, data.data())
				best_time_data = data
			data = TrackSaveableData.new(track.checkpoints.size())
	)

func _physics_process(_delta: float) -> void:
	data.snapshot(car.car_mesh)


func collect(cp: int) -> void:
	var time := best_time_data.checkpoints[cp] if best_time_data else -1.0
	time = best_time_data.time if cp == -1 and time != -1.0 else time
	splits.update(timer.now(), time)
	data.collect(cp, timer.now())


func _on_intro_camera_race_started() -> void:
	start_frame = Engine.get_physics_frames()
