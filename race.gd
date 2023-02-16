extends Node3D
class_name Race

# in order of initialization
var car_scene: PackedScene
var track_loader_scene: PackedScene
var ghost_scene: PackedScene
var track_res: TrackResource
var track: TrackLoader
var data: TrackSaveableData
var best_time_data: TrackSaveableData
var car: Car
var ghost: GhostCar
var start_frame: int

var current_lap := 0
var playing := false
var timer := GameTimer.new()

const SaveLoad := preload("res://addons/@bendn/remap/private/SaveLoadUtils.gd")
const saves := "user://%s.trackdata"

signal next_lap
signal created_car(car: Car)
signal created_ghost(ghost: GhostCar)
signal finished
signal split(time: float, prev_time: float)

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
	ghost.global_position = best_time_data.loadshot(0)[0]
	ghost.global_rotation = best_time_data.loadshot(0)[1]
	ghost.hide()
	created_ghost.emit(ghost)

func mkcar() -> void:
	car = HumanCar.attach(car_scene)
	car.visible = false
	add_child(car)
	car.rotation = track.start_rot + Vector3(0, PI, -PI/2)
	car.global_position = track.start_pos + Vector3(0, 2, 0) - (car.ball.global_transform.basis.z * 2) # bump forward a teensy bit
	car.visible = true
	created_car.emit(car)
	print("car created")

func _ready() -> void:
	set_physics_process(false)
	track = track_loader_scene.instantiate()
	track.track = track_res
	add_child(track)
	data = TrackSaveableData.new(track_res.checkpoints.size(), track_res.laps)
	best_time_data = TrackSaveableData._load(saves % track_res.name)
	mkcar()
	if best_time_data:
		mkghost()
	connect_checkpoints()
	add_child(timer)

func connect_checkpoints() -> void:
	for i in len(track.checkpoints):
		track.checkpoints[i].collected.connect(passed_cp.bind(i))
	track.finish.collected.connect(passed_finish)

func passed_cp(cp: int) -> void: if playing and data.checkpoints[current_lap][cp] < 0: collect(cp)

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
			SaveLoad.save(saves % track_res.name, data.data())
		data = TrackSaveableData.new(track.checkpoints.size())
	else:
		current_lap += 1
		next_lap.emit()

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
	time = best_time_data.time if (not track_res.laps or track_res.laps == current_lap + 1) and cp == -1 and time != -1.0 else time
	split.emit(timer.now(), time)
	data.collect(current_lap, cp, timer.now())


func start() -> void:
	timer.start()
	start_frame = Engine.get_physics_frames()
	playing = true
	car.start()
	set_physics_process(true)
