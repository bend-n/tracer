extends TrackSelect
class_name BuiltinTrackSelect

func _ready() -> void:
	_load()
	super()

func _load():
	var file := FileAccess.open("res://tracks.cfg", FileAccess.READ)
	while !file.eof_reached():
		var line := file.get_line()
		if line == "!" || line.is_empty():
			return
		tracks.append(EditorMarshalling.s2td(line))

func add(t: TrackResource):
	var file := FileAccess.open("res://tracks.cfg", FileAccess.READ_WRITE)
	file.store_line(EditorMarshalling.td2s(t))
	file.close()
	print("added %s!" % EditorMarshalling.td2s(t))
	tracks.append(t)
	mkbutton(t)

func delete(t: TrackResource):
	tracks.erase(t)
	store_all()

func store_all():
	var file := FileAccess.open("res://tracks.cfg", FileAccess.WRITE)
	for t in tracks:
		file.store_line(EditorMarshalling.td2s(t))
