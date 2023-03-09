extends Node3D
class_name GhostWatcher

@export var ghost_scene: PackedScene
@export var track_loader_scene: PackedScene
@export var hud_scene: PackedScene

signal finished
signal next_lap

var start_frame: int
var ghost: GhostCar
var hud: HUD
var timer := GameTimer.new()
var current_lap := 0
var current_cp := 0

func _ready() -> void:
	var track_loader: TrackLoader = track_loader_scene.instantiate()
	track_loader.track = Globals.playing
	add_child(track_loader)

	ghost = ghost_scene.instantiate()
	add_child(ghost)
	ghost.show()
	ghost.update(Globals.ghost.load_snap(0), -1)
	add_child(CarCamera.new(ghost))

	add_child(timer)
	timer.start()

	hud = hud_scene.instantiate()
	hud.assigned.emit(ghost, ghost, timer, track_loader)
	add_child(hud)
	next_lap.connect(hud.laps.increment)

	start_frame = Engine.get_physics_frames()


func _physics_process(delta: float) -> void:
	var frame := Engine.get_physics_frames() - start_frame;

	# splits
	if Globals.ghost.snapped_checkpoints[current_lap][current_cp] == frame:
		hud.splits.update(Globals.ghost.checkpoints[current_lap][current_cp], -1)
		if len(Globals.ghost.checkpoints[current_lap]) < current_cp + 1:
			current_cp += 1
		elif len(Globals.ghost.checkpoints) < current_lap + 1:
			current_lap += 1
			current_cp = 0
			next_lap.emit()
	if Globals.ghost.snap_count == frame:
		hud.splits.update(Globals.ghost.time, -1)
		set_physics_process(false)
		timer.elapsed_time = Globals.ghost.time
		timer.stop()
		finished.emit()
		ghost.reset(false)
		queue_free()
		return

	ghost.update(Globals.ghost.load_snap(frame), delta)
