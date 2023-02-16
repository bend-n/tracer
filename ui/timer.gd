extends Label

var timer: GameTimer

func assigned(_car, _ghost, _timer: GameTimer) -> void:
	timer = _timer

func _process(_delta: float) -> void:
	text = "祥 %s" % timer.fmt_now()