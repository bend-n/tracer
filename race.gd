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
const saves := "user://%s.ghost"

signal next_lap
signal created_car(car: Car)
signal created_ghost(ghost: GhostCar)
signal finished
signal split(time: float, prev_time: float)
signal reset

func _init(t: TrackResource, _car_scene, _ghost_scene, _track_loader_scene) -> void:
	car_scene = _car_scene
	ghost_scene = _ghost_scene
	track_loader_scene = _track_loader_scene
	track_res = t

func mkghost() -> void:
	var g: Node3D = ghost_scene.instantiate()
	g.set_script(load("res://classes/ghost.gd"))
	ghost = g
	add_child(ghost)
	reset_ghost()
	created_ghost.emit(ghost)

func reset_ghost() -> void:
	if best_time_data:
		ghost.global_position = best_time_data.load_snap(0)[0]
		ghost.global_rotation = best_time_data.load_snap(0)[1]
	ghost.hide()

func reset_car() -> void:
	await get_tree().physics_frame
	car.rotation = track.start_rot + Vector3(0, PI, -PI/2)
	car.global_position = track.start_pos + Vector3(0, 2, 0) - (car.global_transform.basis.z * 2) # bump forward a teensy bit
	car.engine_force = 0
	car.current_gear = 0
	car.linear_velocity = Vector3.ZERO
	car.angular_velocity = Vector3.ZERO
	car.steering = 0
	for p in car.particles:
		p.emitting = false
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
	best_time_data = GhostData._load(saves % track_res.name)
	mkcar()
	mkghost()
	connect_checkpoints()
	add_child(timer)

func _input(event: InputEvent) -> void:
	if event.is_action("reset") and playing:
		playing = false
		if best_time_data:
			if ghost:
				reset_ghost()
		await reset_car()
		set_physics_process(false)
		data.clear()
		timer.reset()
		reset.emit()

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
		finished.emit()
		playing = false
		print("finished")
		timer.stop()
		if not best_time_data or data.time < best_time_data.time:
			print("new pb!")
			data.save(saves % track_res.name)
	else:
		current_lap += 1
		next_lap.emit()

func _physics_process(_delta: float) -> void:
	data.snapshot(car)
	if best_time_data:
		if best_time_data.snaps - 1 < Engine.get_physics_frames() - start_frame:
			if ghost.visible:
				print("ran out of snaps, hiding ghost")
				ghost.hide()
			return
		var shot := best_time_data.load_snap(Engine.get_physics_frames() - start_frame)
		ghost.update(shot[0], shot[1], shot[2])
		ghost.visible = (ghost.global_position.distance_squared_to(car.global_position) > 10)

func collect(cp: int) -> void:
	if cp != -1:
		car.checkpoint_sound.play()
	var time := best_time_data.get_time(current_lap, cp) if best_time_data else -1.0
	time = best_time_data.time if (not track_res.laps or track_res.laps == current_lap + 1) and cp == -1 and time != -1.0 else time
	split.emit(timer.now(), time)
	data.collect(current_lap, cp, timer.now())


func start() -> void:
	timer.start()
	start_frame = Engine.get_physics_frames()
	playing = true
	car.start()
	set_physics_process(true)
