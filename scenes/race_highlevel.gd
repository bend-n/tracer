extends Splitscreen

@export var hud_scene: PackedScene
@export var countdown_scene: PackedScene
@export var finish_scene: PackedScene

## For lowlevel race
@export_group("racing stuff")
@export var car_scene: PackedScene
@export var ghost_scene: PackedScene
@export var track_loader_scene: PackedScene

var race: Race
var huds: Array[HUD]

func _ready() -> void:
	race = Race.new(Globals.playing, Globals.ghost, car_scene, ghost_scene, track_loader_scene)
	race.did_reset.connect(count_in)
	add_child(race)
	add_player()
	super()

# cant call it join because of overriding and stuff
func add_player() -> void:
	await get_tree().physics_frame
	var c_cam := CarCamera.new(race.car)
	var i_cam := IntroCam.new(Globals.playing, c_cam)
	var v := join()
	v.viewport.add_child(c_cam)
	v.viewport.add_child(i_cam)
	var hud = hud_scene.instantiate()
	hud.assigned.emit(race.car, race.ghost, race.timer, race.track)
	v.add_child(hud)
	race.split.connect(hud.splits.update)
	race.next_lap.connect(hud.laps.increment)
	huds.append(hud)
	i_cam.finished.connect(count_in)
	race.did_reset.connect(c_cam.reset)
	race.did_reset.connect(hud.laps.reset)
	race.finished.connect(func(t: float, p_t: float):
		var finish: FinishUI = finish_scene.instantiate()
		hud.add_child(finish)
		finish.set_time(t, p_t)
		finish.retry.connect(func():
			race.reset()
			finish.queue_free()
			get_tree().paused = false
		)
	)

func count_in():
	var countdown := countdown_scene.instantiate()
	huds[0].add_child(countdown)
	countdown.finished.connect(race.start)
