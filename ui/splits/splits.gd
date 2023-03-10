extends VBoxContainer
class_name Splits

@export var diff: SplitsDifference
@export var current: Label

var timer: SceneTreeTimer

func update(time: float, prev_time: float) -> void:
	show()
	diff.update(time, prev_time)
	current.text = GameTimer.format(time)
	timer = get_tree().create_timer(5)
	timer.timeout.connect(hide)

func _ready() -> void:
	hide()
