extends TrackSelect
class_name BuiltinTrackSelect

func _ready() -> void:
	_load()
	mkbuttons(Globals.builtin_tracks)
	super()

func _load():
	var str := FileAccess.get_file_as_string("res://tracks.cfg")
	var tracks: Array = str_to_var(str)
	for track in tracks:
		var loaded := TrackResource.from_d(track)
		loaded.builtin = true
		Globals.builtin_tracks.append(loaded)

func add(t: TrackResource):
	mkbutton(t)
	Globals.builtin_tracks.append(t)
	BuiltinTrackSelect.store_all()

static func delete(t: TrackResource):
	Globals.builtin_tracks.erase(t)
	BuiltinTrackSelect.store_all()

static func store_all():
	var arr: Array = Globals.builtin_tracks.map(func(t: TrackResource) -> Dictionary: return t.to_d())
	var file := FileAccess.open("res://tracks.cfg", FileAccess.WRITE)
	file.store_string(var_to_str(arr))
