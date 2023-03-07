class_name GhostData
extends Resource

var time: float
var checkpoints: Array
# i hope this is performant
var snaps: Array#[Dictionary]
var snap_count := 0

func snapshot(obj: Car):
	snaps.append(CarVars.new(obj).to_dict())
	snap_count += 1

## returns a CarVars dictionary
func load_snap(i: int) -> Dictionary:
	return snaps[i]

func save(path: String) -> void:
	GhostData._save_file(path, {checkpoints = checkpoints, time = time, snaps = snaps, snap_count = snap_count})

func _init(num_checkpoints := 0, laps := 0) -> void:
	for i in laps:
		var arr := []
		arr.resize(num_checkpoints + 1)
		arr.fill(-1)
		checkpoints.append(arr)

func clear() -> void:
	for lap in checkpoints:
		lap.fill(-1)
	snaps.clear()
	time = 0
	snap_count = 0

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
	return checkpoints[lap][cp]

static func from_d(d: Dictionary) -> GhostData:
	var obj := GhostData.new()
	obj.time = d.time
	obj.checkpoints = d.checkpoints
	obj.snap_count = d.snap_count
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
