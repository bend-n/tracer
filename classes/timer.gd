extends Node
class_name GameTimer

var elapsed_time: float = 0.0

func _ready() -> void:
	stop()

func start() -> void:
	set_process(true)

func stop() -> void:
	set_process(false)

func reset() -> void:
	stop()
	elapsed_time = 0.0

func now() -> float:
	return elapsed_time

## format a number of seconds into m:ss.ms with padding
static func format(time: float) -> String:
	return "%01d:%02d.%02d" % [time / 60, fmod(time, 60), fmod(time * 1000, 100)]

## format a number of seconds into mm:ss.msc without padding ( i really need to test these )
static func format_precise(time: float) -> String:
	return "%02d:%02d:%03d" % [time / 60, fmod(time, 60), fmod(time * 1000, 1000)]

func fmt_now() -> String:
	return GameTimer.format(elapsed_time)

func _process(delta: float) -> void:
	elapsed_time += delta
