class_name TrackSaveableData
extends Resource

var time: float
var checkpoints: Array#[PackedFloat32Array]
var positional := {
	origins = PackedVector3Array(),
	rotations = PackedVector3Array(),
	steering = PackedFloat32Array(),
	snaps = 0,
}

func save(path: String) -> void:
	_save_file(path, {checkpoints = checkpoints, positional = positional, time = time})

func _init(num_checkpoints := 0, laps := 0) -> void:
	for i in laps:
		var arr := []
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
	positional.origins.append(obj.global_position)
	positional.rotations.append(obj.global_rotation)
	positional.steering.append(snappedf(obj.steering, .1)) # FastLZ benefits from repetition
	positional.snaps += 1

func loadshot(frame: int) -> Array:
	return [positional.origins[frame], positional.rotations[frame], positional.steering[frame]]

func snaps() -> int:
	return positional.snaps

static func from_d(d: Dictionary) -> TrackSaveableData:
	var obj := TrackSaveableData.new(0)
	obj.time = d.time
	obj.checkpoints = d.checkpoints
	obj.positional = d.positional
	return obj


## Saves a basic dictionary to a path.
static func _save_file(path: String, data: Dictionary) -> void:
	var file := FileAccess.open_compressed(path, FileAccess.WRITE, FileAccess.COMPRESSION_FASTLZ)
	file.store_buffer(var_to_bytes(data))

## Loads a basic dictionary out of a file.
static func _load_file(path: String) -> Dictionary:
	if FileAccess.file_exists(path):
		var file := FileAccess.open_compressed(path, FileAccess.READ, FileAccess.COMPRESSION_FASTLZ)
		var text := file.get_buffer(file.get_length())
		var dict := {}
		if text:
			dict = bytes_to_var(text)
		return dict
	_save_file(path, {})  # create file if it doesn't exist
	return {}

static func _load(path: String) -> TrackSaveableData:
	var res := _load_file(path)
	if res.is_empty():
		return null
	return TrackSaveableData.from_d(res)
