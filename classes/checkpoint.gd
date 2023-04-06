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

func un_highlight():
	if !_previous_material:
		push_error("no mat!")
		return
	mesh.set_surface_override_material(0, _previous_material)

var _previous_material: BaseMaterial3D
func highlight() -> void:
	_previous_material = mesh.get_active_material(0)
	mesh.set_surface_override_material(0, MatMap.get_highlight(_previous_material))
