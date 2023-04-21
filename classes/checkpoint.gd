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

@export var mesh: MeshInstance3D # i want traits (tho macros would be good 2)

func un_highlight(): mesh.set_surface_override_material(0, MatMap.map[mat])
func highlight() -> void: mesh.set_surface_override_material(0, MatMap.get_highlight(mat))
func default_mat(): return 8
