extends GridContainer
class_name TrackEditorList

const trackbutton := preload("res://track_editable_button.tscn")
const editor := preload("res://ui/editor/track_editor.tscn")

@export var other_track_select: TrackSelect

func _ready() -> void:
	if not DirAccess.dir_exists_absolute(Globals.TRACKS.get_base_dir()):
		DirAccess.make_dir_recursive_absolute(Globals.TRACKS.get_base_dir())
	var d := DirAccess.open(Globals.TRACKS.get_base_dir())
	d.list_dir_begin()
	var item := d.get_next()
	while !item.is_empty():
		var track := TrackResource._load(Globals.TRACKS.get_base_dir().path_join(item))
		var ghost := GhostData._load(Globals.SAVES % track.name)
		var button := trackbutton.instantiate() as TrackEditableButton
		add_child(button)
		# hopefully this is all reference based and i wont have any issues whatsoever
		button.init(track, ghost)
		button.play.connect(other_track_select.play.bind(track, ghost))
		button.watch.connect(other_track_select.watch.bind(track, ghost))
		button.edit.connect(edit.bind(track))
		item = d.get_next()
	if get_child_count() > 0:
		(get_child(0) as TrackButton).button.grab_focus()

func edit(track: TrackResource) -> void:
	print("edit %s" % track.name)
	Globals.editing = track
	other_track_select.add_to_main(editor)
