extends GridContainer

@export var tracks: Array[TrackResource]
@export var race: PackedScene

func _ready() -> void:
	for track in tracks:
		var button := Button.new()
		add_child(button)
		button.name = track.name
		button.text = track.name
		button.pressed.connect(track_selected.bind(track))

func track_selected(track: TrackResource) -> void:
	print("play %s" % track.name)
	Globals.playing = track
	get_tree().change_scene_to_packed(race)