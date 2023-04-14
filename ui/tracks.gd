extends TrackSelect
class_name BuiltinTrackSelect

func _ready() -> void:
	_load()
	mkbuttons(Globals.builtin_tracks)
	super()

func _load():
	var file := FileAccess.open("res://tracks.cfg", FileAccess.READ)
	while !file.eof_reached():
		var line := file.get_line()
		if line == "!" || line.is_empty():
			return
		var t := EditorMarshalling.s2td(line)
		t.builtin = true
		Globals.builtin_tracks.append(t)

func add(t: TrackResource):
	var file := FileAccess.open("res://tracks.cfg", FileAccess.READ_WRITE)
	mkbutton(t)
	Globals.builtin_tracks.append(t)
	store_all()

static func delete(t: TrackResource):
	Globals.builtin_tracks.erase(t)
	store_all()

static func store_all():
	var file := FileAccess.open("res://tracks.cfg", FileAccess.WRITE)
	for t in Globals.builtin_tracks:
		file.store_line(EditorMarshalling.td2s(t))
