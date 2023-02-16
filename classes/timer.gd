extends Node
class_name GameTimer

var elapsed_time: float = 0.0

func _ready() -> void:
	stop()

func start() -> void:
	set_process(true)

func stop() -> void:
	set_process(false)

func now() -> float:
	return elapsed_time

## format a number of seconds into m:s.ms
static func format(time: float) -> String:
	return "%01d:%02d.%02d" % [time / 60, fmod(time, 60), fmod(time * 1000, 100)]

func fmt_now() -> String:
	return GameTimer.format(elapsed_time)

func _process(delta: float) -> void:
	elapsed_time += delta