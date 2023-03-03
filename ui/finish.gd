extends ColorRect
class_name FinishUI

@export var diff: SplitsDifference
@export var time_: Label
@export var flag: Label
@export var focus: Control

signal retry
signal next
signal quit
signal difference(diff: SplitsDifference.Change)

func set_time(time: float, prev_time: float):
	time_.text = GameTimer.format_precise(time)
	if prev_time < 0 or SplitsDifference.diff(time, prev_time) == SplitsDifference.Change.EQUAL:
		diff.hide()
		flag.text = "󰈻"
		flag.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	else:
		flag.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		var d := SplitsDifference.diff(time, prev_time);
		match d:
			SplitsDifference.Change.LOSS: flag.text = "󰮙"
			SplitsDifference.Change.GAIN: flag.text = "󰮚"
		diff.update(time, prev_time)
		difference.emit(d)

func _ready() -> void:
	focus.grab_focus()
