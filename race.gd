extends Node3D
class_name Race

# in order of initialization
var car_scene: PackedScene
var track_loader_scene: PackedScene
var ghost_scene: PackedScene
var track_res: TrackResource
var track: TrackLoader
var data: GhostData
var best_time_data: GhostData
var car: Car
var ghost: GhostCar
var start_frame: int

var current_lap := 0
var playing := false
var timer := GameTimer.new()

const SaveLoad := preload("res://addons/@bendn/remap/private/SaveLoadUtils.gd")

signal next_lap
signal created_car(car: Car)
signal created_ghost(ghost: GhostCar)
signal finished(time: float, prev_time: float)
signal split(time: float, prev_time: float)
signal did_reset

func _init(t: TrackResource, ghost_data: GhostData, _car_scene, _ghost_scene, _track_loader_scene) -> void:
	car_scene = _car_scene
	ghost_scene = _ghost_scene
	track_loader_scene = _track_loader_scene
	track_res = t
	best_time_data = ghost_data

func mkghost() -> void:
	ghost = ghost_scene.instantiate()
	add_child(ghost)
	reset_ghost()
	created_ghost.emit(ghost)

func reset_ghost() -> void:
	if best_time_data:
		ghost.update(best_time_data.load_snap(0), -1)
		ghost.engine.volume = .2
	else:
		ghost.engine.volume = 0
		ghost.global_position = track.start_pos + Vector3(0, 2, 0) - (car.global_transform.basis.z * 2)
		ghost.rotation = track.start_rot + Vector3(0, PI, -PI/2)
	ghost.reset()
	ghost.hide()

func reset_car() -> void:
	await get_tree().physics_frame
	car.rotation = track.start_rot + Vector3(0, PI, -PI/2)
	car.global_position = track.start_pos + Vector3(0, 2, 0) - (car.global_transform.basis.z * 2) # bump forward a teensy bit
	car.linear_velocity = Vector3.ZERO
	car.angular_velocity = Vector3.ZERO
	car.current_gear = 0
	car.reset()

func mkcar() -> void:
	car = HumanCar.attach(car_scene)
	add_child(car)
	reset_car()
	created_car.emit(car)

func _ready() -> void:
	set_physics_process(false)
	track = track_loader_scene.instantiate()
	track.track = track_res
	add_child(track)
	data = GhostData.new(track_res.checkpoints.size(), track_res.laps)
	mkcar()
	mkghost()
	connect_checkpoints()
	add_child(timer)

func _input(event: InputEvent) -> void:
	if event.is_action("reset") and playing:
		reset()

func reset() -> void:
	playing = false
	if best_time_data:
		if ghost:
			reset_ghost()
	await reset_car()
	set_physics_process(false)
	current_lap = 0
	data.clear()
	timer.reset()
	did_reset.emit()

func connect_checkpoints() -> void:
	for i in len(track.checkpoints):
		track.checkpoints[i].collected.connect(passed_cp.bind(i))
	track.finish.collected.connect(passed_finish)

func passed_cp(cp: int) -> void: if playing and !data.has_collected(current_lap, cp): collect(cp)

func passed_finish() -> void:
	if !playing: return
	for i in len(data.checkpoints[current_lap]) - 1:
		if data.checkpoints[current_lap][i] < 0:
			return
	collect(-1)
	if track_res.laps - 1 == current_lap:
		print("finished")
		playing = false
		timer.stop()
		car.reset()
		if not best_time_data or data.time < best_time_data.time:
			print("new pb!")
			finished.emit(data.time, best_time_data.time if best_time_data else -1.0)
			data.save(Globals.SAVES % track_res.name)
			best_time_data = data
		else:
			finished.emit(data.time, best_time_data.time)
		data = GhostData.new(track_res.checkpoints.size(), track_res.laps)
	else:
		current_lap += 1
		next_lap.emit()

func _physics_process(delta: float) -> void:
	data.snapshot(car)
	if best_time_data:
		if best_time_data.snap_count - 1 < Engine.get_physics_frames() - start_frame:
			if ghost.visible:
				print("ran out of snaps, hiding ghost")
				ghost.hide()
			return
		ghost.update(best_time_data.load_snap(Engine.get_physics_frames() - start_frame), delta)
		ghost.visible = (ghost.global_position.distance_squared_to(car.global_position) > 10)
		ghost.engine.volume = lerpf(ghost.engine.volume, .7, delta) if (ghost.global_position.distance_squared_to(car.global_position) > 20) else lerpf(ghost.engine.volume, .2, delta * 3)

func collect(cp: int) -> void:
	if cp != -1:
		car.checkpoint_sound.play()
	var time := best_time_data.get_time(current_lap, cp) if best_time_data else -1.0
	time = best_time_data.time if (not track_res.laps or track_res.laps == current_lap + 1) and cp == -1 and time != -1.0 else time
	split.emit(snappedf(timer.now(), .001), time)
	data.collect(current_lap, cp, snappedf(timer.now(), .001))

func start() -> void:
	timer.start()
	start_frame = Engine.get_physics_frames()
	playing = true
	car.start()
	set_physics_process(true)
