extends PanelContainer

@export var track: TrackLoader
@export var label: Label

var lap := 0

func _ready() -> void:
	visible = track.track.laps > 1
	increment()

func increment() -> void:
	lap += 1
	label.text = " %d/%d" % [lap, track.track.laps]
