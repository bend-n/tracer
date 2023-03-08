extends GridContainer

@export var tracks: Array[TrackResource]
@export var race: PackedScene
@export var trackbutton: PackedScene

func _ready() -> void:
	for track in tracks:
		var button := trackbutton.instantiate()
		add_child(button)
		var ghost := GhostData._load(Globals.SAVES % track.name)
		await button.init(track, ghost)
		button.pressed.connect(track_selected.bind(track))

func track_selected(track: TrackResource) -> void:
	print("play %s" % track.name)
	Globals.playing = track
	get_tree().change_scene_to_packed(race)
