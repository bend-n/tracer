class_name TrackSaveableData
extends RefCounted

const SaveLoad := preload("res://addons/@bendn/remap/private/SaveLoadUtils.gd")

var time: float
var checkpoints: PackedFloat32Array
var positional := {
	origins = PackedVector3Array(),
	rotations = PackedVector3Array(),
	steering = PackedFloat32Array(),
	snaps = 0,
}

func data() -> Dictionary:
	return ({time = time, checkpoints = checkpoints, positional = positional})

func _init(num_checkpoints: int) -> void:
	checkpoints.resize(num_checkpoints)
	checkpoints.fill(-1)

func collect(cp: int, now: float) -> void:
	if cp == -1: # fin
		time = now
	else:
		checkpoints[cp] = now

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
	var obj := TrackSaveableData.new(0)
	obj.checkpoints = d.get("checkpoints", [])
	obj.time = d.get("time", -1)
	obj.positional = d.get("positional", {origins = [], rotations = [], steering = [], snaps = 0})
	return obj

static func _load(path: String) -> TrackSaveableData:
	var res := SaveLoad.load_file(path)
	if res.is_empty():
		return null
	return TrackSaveableData.from_d(res)
