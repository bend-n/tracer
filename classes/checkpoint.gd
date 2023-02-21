extends PathFollow3D
class_name CheckPoint

signal collected

@export var needs_collision := true

func enter() -> void:
		collected.emit()
