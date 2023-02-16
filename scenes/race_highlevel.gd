extends Splitscreen

@export var hud_scene: PackedScene
@export var countdown_scene: PackedScene

## For lowlevel race
@export var car_scene: PackedScene
@export var ghost_scene: PackedScene
@export var track_loader_scene: PackedScene

var race: Race
var huds: Array[HUD]

func _ready() -> void:
	race = Race.new(Globals.playing, car_scene, ghost_scene, track_loader_scene)
	add_child(race)
	add_player()
	super()

# cant call it join because of overriding and stuff
func add_player() -> void:
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
	i_cam.finished.connect(func(): var countdown := countdown_scene.instantiate(); v.add_child(countdown); countdown.finished.connect(func(): race.start()))
