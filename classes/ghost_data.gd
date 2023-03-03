class_name GhostData
extends Resource

var time: float
var checkpoints: Array
var positions: PackedVector3Array = []
var rotations: PackedVector3Array = []
var steering: PackedFloat32Array = []
var snaps := 0

func snapshot(obj: Car):
	positions.append(obj.global_position)
	rotations.append(obj.global_rotation)
	steering.append(snappedf(obj.steering, .1)) # FastLZ benefits from repetition
	snaps += 1

## returns [position, rotation, steering]
func load_snap(i: int) -> Array:
	return [positions[i], rotations[i], steering[i]]

func save(path: String) -> void:
	GhostData._save_file(path, {checkpoints = checkpoints, positions = positions, rotations = rotations, steering = steering, time = time, snaps = snaps})

func _init(num_checkpoints := 0, laps := 0) -> void:
	for i in laps:
		var arr := []
		arr.resize(num_checkpoints + 1)
		arr.fill(-1)
		checkpoints.append(arr)

func clear() -> void:
	for lap in checkpoints:
		lap.fill(-1)
	positions = []
	rotations = []
	steering = []
	time = 0
	snaps = 0

func collect(lap: int, cp: int, now: float) -> void:
	now = snappedf(now, .001) # 3dec precision
	if lap == len(checkpoints) - 1 && cp == -1:
		checkpoints[lap][cp] = now
		time = now
	else:
		checkpoints[lap][cp] = now

func has_collected(lap: int, cp: int) -> bool:
	return checkpoints[lap][cp] != -1

func get_time(lap: int, cp: int) -> float:
	return snappedf(checkpoints[lap][cp], .001) # ive noticed compression can add .00000157 so we snap it back down

static func from_d(d: Dictionary) -> GhostData:
	var obj := GhostData.new()
	obj.time = d.time
	obj.checkpoints = d.checkpoints
	obj.positions = d.positions
	obj.rotations = d.rotations
	obj.steering = d.steering
	obj.snaps = d.snaps
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

## Creates a [GhostData] from a file
static func _load(path: String) -> GhostData:
	var res := _load_file(path)
	if res.is_empty():
		return null
	return GhostData.from_d(res)
