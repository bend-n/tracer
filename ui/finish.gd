extends ColorRect
class_name FinishUI

@export var diff: SplitsDifference
@export var time_: Label
@export var flag: Label
@export var focus: Control

signal retry
signal next
signal quit
signal difference(diff: int)

func set_time(time: float, prev_time: float):
	time_.text = GameTimer.format_precise(time)
	var d := SplitsDifference.diff(time, prev_time)
	if prev_time < 0 or d == SplitsDifference.Change.EQUAL:
		diff.hide()
		flag.text = "󰈻"
		flag.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		difference.emit(-1 if prev_time < 0 else d)
	else:
		flag.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		match d:
			SplitsDifference.Change.LOSS: flag.text = "󰮙"
			SplitsDifference.Change.GAIN: flag.text = "󰮚"
		diff.update(time, prev_time)
		difference.emit(d)

func _ready() -> void:
	focus.grab_focus()
