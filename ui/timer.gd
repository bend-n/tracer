extends Label

var timer: GameTimer

func assigned(_car, p_timer: GameTimer) -> void:
	timer = p_timer

func _process(_delta: float) -> void:
	text = "祥 %s" % timer.fmt_now()
