extends SplitsDifference

@export var gain_color: Color
@export var loss_color: Color

func style(d: Change) -> void:
	match d:
		Change.LOSS: label_settings.font_color = loss_color
		Change.GAIN: label_settings.font_color = gain_color
		Change.EQUAL:
			hide()

func format(t: float) -> String:
	return GameTimer.format_precise(t)
