extends Block
class_name CheckPoint

signal collected

@export var player_detector: Area3D

func enter(_var = null):
	collected.emit()

func _ready() -> void:
	super()
	if editor:
		player_detector.queue_free()
	else:
		player_detector.body_entered.connect(enter)
