extends PanelContainer
class_name LapCounter

var track: TrackLoader
@export var label: Label

var lap := 0:
	set(l):
		lap = l
		label.text = " %d/%d" % [lap, track.track.laps]

func increment() -> void:
	lap += 1

func assigned(_car, _timer, _track: TrackLoader) -> void:
	track = _track
	visible = track.track.laps > 1
	increment()

func reset() -> void:
	lap = 1
