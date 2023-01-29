extends PanelContainer

@export var gain_style: StyleBox
@export var loss_style: StyleBox
@export var neutral_style: StyleBox
@export var label: Label

enum Change { GAIN, LOSS, EQUAL }

func update(time: float, prev_time: float) -> void:
	if prev_time < 0: # no time set
		hide()
		return
	else:
		show() # shouldnt be needed but just to be carefull
	var change := diff(time, prev_time)
	style(change)
	match change:
		Change.LOSS: label.text = "+" + GameTimer.format(time - prev_time)
		Change.GAIN: label.text = "-" + GameTimer.format(prev_time - time)
		Change.EQUAL: label.text = "0:00.00"

func diff(t1: float, t2: float) -> int:
	if is_equal_approx(t1, t2):
		return Change.EQUAL
	return Change.GAIN if t1 < t2 else Change.LOSS

func style(d: int) -> void:
	match d:
		Change.LOSS: add_theme_stylebox_override(&"panel", loss_style)
		Change.GAIN: add_theme_stylebox_override(&"panel", gain_style)
		Change.EQUAL: add_theme_stylebox_override(&"panel", neutral_style)
