class_name TrackSaveableData
extends Resource

const SaveLoad := preload("res://addons/@bendn/remap/private/SaveLoadUtils.gd")

var time: float
var checkpoints: Array[PackedFloat32Array]
var positional := {
	origins = PackedVector3Array(),
	rotations = PackedVector3Array(),
	steering = PackedFloat32Array(),
	snaps = 0,
}

func data() -> Dictionary:
	return ({time = time, checkpoints = checkpoints, positional = positional})

func _init(num_checkpoints := 0, laps := 0) -> void:
	for i in laps:
		var arr: PackedFloat32Array = []
		arr.resize(num_checkpoints + 1)
		arr.fill(-1)
		checkpoints.append(arr)

func collect(lap: int, cp: int, now: float) -> void:
	if lap == len(checkpoints) - 1 && cp == -1:
		checkpoints[lap][cp] = now
		time = now
	else:
		checkpoints[lap][cp] = now

func get_time(lap: int, cp: int) -> float:
	return checkpoints[lap][cp]

func snapshot(obj: Car) -> void:
	positional.origins.append(obj.car_mesh.global_position)
	positional.rotations.append(obj.car_mesh.global_rotation)
	positional.steering.append(obj._steering)
	positional.snaps += 1

func loadshot(frame: int) -> Array:
	return [positional.origins[frame], positional.rotations[frame], positional.steering[frame]]

func snaps() -> int:
	return positional.snaps

static func from_d(d: Dictionary) -> TrackSaveableData:
	if !d.has_all(["checkpoints", "positional", "time"]) and d.positional.has_all(["origins", "rotations", "steering", "snaps"]):
		return null
	var obj := TrackSaveableData.new(0)
	obj.checkpoints = d.checkpoints
	obj.time = d.time
	obj.positional = d.positional
	return obj

static func _load(path: String) -> TrackSaveableData:
	var res := SaveLoad.load_file(path)
	if res.is_empty():
		return null
	return TrackSaveableData.from_d(res)
