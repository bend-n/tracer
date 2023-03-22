extends GridContainer
class_name TrackEditorList

const trackbutton := preload("res://track_editable_button.tscn")

func _ready() -> void:
	if not DirAccess.dir_exists_absolute(Globals.TRACKS.get_base_dir()):
		DirAccess.make_dir_recursive_absolute(Globals.TRACKS.get_base_dir())
	var d := DirAccess.open(Globals.TRACKS.get_base_dir())
	d.list_dir_begin()
	var item := d.get_next()
	while !item.is_empty():
		var track := TrackResource._load(Globals.TRACKS.get_base_dir().path_join(item))
		var ghost := GhostData._load(Globals.SAVES % track.name)
		var button: TrackButton = trackbutton.instantiate()
		add_child(button)
		button.init(track, ghost)
		item = d.get_next()
	if get_child_count() > 0:
		(get_child(0) as TrackButton).button.grab_focus()

