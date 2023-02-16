extends PanelContainer
class_name LapCounter

var track: TrackLoader
@export var label: Label

var lap := 0

func increment() -> void:
	lap += 1
	label.text = " %d/%d" % [lap, track.track.laps]

func assigned(_car, _ghost, _timer, _track: TrackLoader) -> void:
	track = _track
	visible = track.track.laps > 1
	increment()
