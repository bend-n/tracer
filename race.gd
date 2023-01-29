extends Node3D

@export var car_scene: PackedScene
@export var ghost_scene: PackedScene
@export var track: TrackLoader
@export var splits: Control
@export var timer: Control
@onready var data := TrackSaveableData.new(track.checkpoints.size(), track.track.laps if track.track.laps else 1)
@onready var best_time_data := TrackSaveableData._load(saves % track.track.name)
var car: Car
var ghost: GhostCar
var current_lap := 0
var start_frame: int
var playing := false

const SaveLoad := preload("res://addons/@bendn/remap/private/SaveLoadUtils.gd")
const saves := "user://%s.trackdata"

signal next_lap
signal created_car(car: Car)
signal finished

func mkghost() -> void:
	var g: Node3D = ghost_scene.instantiate()
	g.set_script(load("res://classes/ghost.gd"))
	ghost = g
	add_child(ghost)
	ghost.global_position = best_time_data.loadshot(0)[0]
	ghost.global_rotation = best_time_data.loadshot(0)[1]
	print("ghost created")

func _ready() -> void:
	set_physics_process(false)
	if best_time_data:
		mkghost()
	car = HumanCar.attach(car_scene)
	add_child(car)
	car.ball.freeze = true
	car.visible = false
	car.global_position = track.start_pos + Vector3.UP * 3.5
	car.set_deferred(&"rotation", track.start_rot + Vector3.UP * PI)
	await get_tree().process_frame
	car.global_position = car.global_position - (car.ball.global_transform.basis.z * 2) # bump forward a teensy bit
	car.visible = true
	created_car.emit(car)
	print("car created")
	for i in len(track.checkpoints):
		track.checkpoints[i].collected.connect(
			(func passed_cp(cp: int) -> void: if playing and data.checkpoints[current_lap][i] < 0: collect(cp))
		.bind(i))

	track.finish.collected.connect(
		func passed_finish() -> void:
			if !playing: return
			for i in len(data.checkpoints[current_lap]) - 1:  # no any() function on packedfloat32
				if data.checkpoints[current_lap][i] < 0:
					return
			collect(-1)
			if not track.track.laps or track.track.laps - 1 == current_lap:
				finished.emit()
				playing = false
				print("finished")
				if not best_time_data or data.time < best_time_data.time:
					print("new pb!")
					SaveLoad.save(saves % track.track.name, data.data())
					# best_time_data = data # this messes with the ghost, and doesnt matter yet anyways (until i can reset)
				data = TrackSaveableData.new(track.checkpoints.size())
			else:
				current_lap += 1
				next_lap.emit()
	)

func _physics_process(_delta: float) -> void:
	data.snapshot(car)
	if ghost:
		if best_time_data.snaps() - 1 < Engine.get_physics_frames() - start_frame:
			print("ran out of snaps, removing ghost")
			ghost.queue_free()
			ghost = null
			return
		var shot := best_time_data.loadshot(Engine.get_physics_frames() - start_frame)
		ghost.update(shot[0], shot[1], shot[2])
		ghost.visible = (ghost.global_position.distance_squared_to(car.car_mesh.global_position) > 10)


func collect(cp: int) -> void:
	var time := best_time_data.get_time(current_lap, cp) if best_time_data else -1.0
	time = best_time_data.time if (not track.track.laps or track.track.laps == current_lap + 1) and cp == -1 and time != -1.0 else time
	splits.update(timer.now(), time)
	data.collect(current_lap, cp, timer.now())


func _on_intro_camera_race_started() -> void:
	start_frame = Engine.get_physics_frames()
	playing = true
	set_physics_process(true)
