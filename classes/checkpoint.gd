extends PathFollow3D
class_name CheckPoint

signal collected

var id: int # checkpoint id

@export var needs_collision := true

func enter() -> void:
    collected.emit()