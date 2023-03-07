extends Control

func init(t: float, n: String) -> void:
	$VBoxContainer/name.text = n
	if t < 0:
		$VBoxContainer/time.text = "no time set"
	else:
		$VBoxContainer/time.text = GameTimer.format_precise(t)
