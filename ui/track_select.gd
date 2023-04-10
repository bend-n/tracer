extends GridContainer
class_name TrackSelect

@export var editor: PackedScene = preload("res://ui/editor/track_editor.tscn")
@export var race: PackedScene = preload("res://scenes/race_high.tscn")
@export var ghost_watch: PackedScene = preload("res://scenes/ghost_watcher.tscn")
@export var trackbutton: PackedScene = preload("res://ui/track_button.tscn")
@export var editable := false
@export var builtin := false
@onready var dev = DirAccess.dir_exists_absolute("res://.git")
var tracks: Array[TrackResource]

func _ready() -> void:
	mkbuttons()
	if get_child_count() > 0:
		(get_child(0) as TrackButton).button.grab_focus()

## @virtual
func _on_mkbutton(_button: TrackButton, _track: TrackResource) -> void:
	pass

func mkbutton(track: TrackResource) -> void:
	var button := trackbutton.instantiate() as TrackButton
	button.editable = editable
	button.builtin = builtin
	button.dev = dev
	button.name = track.name
	add_child(button)
	button.init(track, lodg(track.name))

	# this works perfectly because its all reference based, but the ghosts will change, so load them every time
	button.watch.connect(func(): watch(track, lodg(track.name)))
	button.delete.connect(delete.bind(track))
	button.play.connect(func(): play(track, lodg(track.name)))
	button.edit.connect(edit.bind(track))
	_on_mkbutton(button, track)

func mkbuttons() -> void:
	for track in tracks:
		mkbutton(track)

func lodg(n: String) -> GhostData:
	return GhostData._load(Globals.SAVES % n)

func edit(track: TrackResource) -> void:
	Globals.editing = track
	add_to_main(editor)

func play(track: TrackResource, ghost: GhostData) -> void:
	Globals.playing = track
	Globals.ghost = ghost
	add_to_main(race)

func watch(track: TrackResource, ghost: GhostData) -> void:
	Globals.playing = track
	Globals.ghost = ghost
	add_to_main(ghost_watch)

func add_to_main(p: PackedScene) -> void:
	owner.hide()
	var c := p.instantiate()
	get_viewport().add_child(c)
	c.tree_exited.connect(owner.show)

func delete(track: TrackResource):
#	OS.move_to_trash(Globals.TRACKS % track.name)
	DirAccess.remove_absolute(Globals.TRACKS % track.name)
	if FileAccess.file_exists(Globals.THUMBS % track.name):
		DirAccess.remove_absolute(Globals.THUMBS % track.name)
	tracks.erase(track)
