extends GridContainer

@export var tracks: Array[TrackResource]
@export var race: PackedScene
@export var ghost_watch: PackedScene
@export var trackbutton: PackedScene

func _ready() -> void:
	for track in tracks:
		var button: TrackButton = trackbutton.instantiate()
		add_child(button)
		var ghost := GhostData._load(Globals.SAVES % track.name)
		await button.init(track, ghost)
		button.play.connect(play.bind(track, ghost))
		button.watch.connect(watch.bind(track, ghost))

func play(track: TrackResource, ghost: GhostData) -> void:
	print("play %s" % track.name)
	Globals.playing = track
	Globals.ghost = ghost
	get_tree().change_scene_to_packed(race)

func watch(track: TrackResource, ghost: GhostData) -> void:
	print("watch %s" % track.name)
	Globals.playing = track
	Globals.ghost = ghost
	get_tree().change_scene_to_packed(ghost_watch)
