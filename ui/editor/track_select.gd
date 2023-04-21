extends TrackSelect
class_name TrackEditorList

@export var other: BuiltinTrackSelect
var tracks: Array[TrackResource] = []

func _ready() -> void:
	if not DirAccess.dir_exists_absolute(Globals.TRACKS.get_base_dir()):
		DirAccess.make_dir_recursive_absolute(Globals.TRACKS.get_base_dir())
	var d := DirAccess.open(Globals.TRACKS.get_base_dir())
	d.list_dir_begin()
	var item := d.get_next()
	while !item.is_empty():
		tracks.append(TrackResource._load(Globals.TRACKS.get_base_dir().path_join(item)))
		item = d.get_next()
	mkbuttons(tracks)
	super()

func _on_mkbutton(b: TrackButton, t: TrackResource) -> void:
	@warning_ignore("static_called_on_instance")
	b.include.connect(func(): other.add(t); TrackSelect.delete(t); b.queue_free())

func _on_new_pressed() -> void:
	var res := TrackResource.new([])
	var n := 0
	while FileAccess.file_exists(Globals.TRACKS % ("untitled track %d" % n if n != 0 else "untitled track")):
		n+=1
	var nam := "untitled track %d" % n if n != 0 else "untitled track"
	res.name = nam
	edit(res)
	tracks.append(res)
	mkbutton(res)

func _on_import_import(p_track: TrackResource) -> void:
	for track in tracks:
		if track.name == p_track.name:
			return
	p_track.save(Globals.TRACKS % p_track.name)
	mkbutton(p_track)
