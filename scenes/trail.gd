extends Path3D
class_name Trail3D

@export var active: bool = true

func add(p: Vector3) -> void:
	curve.add_point(p)

func _ready() -> void:
	curve = Curve3D.new()
	curve.bake_interval = 2
