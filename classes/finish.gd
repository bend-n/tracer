extends PathFollow3D
class_name Finish

signal collected

@export var needs_collision := true

func enter() -> void:
    collected.emit()