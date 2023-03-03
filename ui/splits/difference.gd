extends Label
class_name SplitsDifference

@export var gain_style: StyleBox
@export var loss_style: StyleBox
@export var neutral_style: StyleBox

enum Change { GAIN, LOSS, EQUAL }

func format(t: float) -> String:
	return GameTimer.format(t)

func update(time: float, prev_time: float) -> void:
	if prev_time < 0: # no time set
		hide()
		return
	else:
		show() # shouldnt be needed but just to be carefull
	var change := SplitsDifference.diff(time, prev_time)
	style(change)
	match change:
		Change.LOSS: text = "+" + format(time - prev_time)
		Change.GAIN: text = "-" + format(prev_time - time)
		Change.EQUAL: text = format(0)

static func diff(t1: float, t2: float) -> int:
	if is_equal_approx(t1, t2):
		return Change.EQUAL
	return Change.GAIN if t1 < t2 else Change.LOSS

func style(d: Change) -> void:
	match d:
		Change.LOSS: add_theme_stylebox_override(&"normal", loss_style)
		Change.GAIN: add_theme_stylebox_override(&"normal", gain_style)
		Change.EQUAL: add_theme_stylebox_override(&"normal", neutral_style)
