extends RayCast3D
class_name MouseCast

@onready var v := get_viewport()
@onready var c := v.get_camera_3d()
var gizmo_just_hit := false
var cast_ray := false
const depth := 2000.0

signal miss
signal hit(coll: Block)

func position_to(e: InputEventMouse):
	global_position = c.project_ray_origin(e.position)
	target_position = c.project_ray_normal(e.position) * depth

func is_left_click(e: InputEvent) -> bool:
	return e is InputEventMouseButton and e.button_index == MOUSE_BUTTON_LEFT and e.is_pressed()

func _input(event: InputEvent) -> void:
	if is_left_click(event):
		position_to(event)
		set_physics_process(true)

func _physics_process(_delta: float) -> void:
	set_physics_process(false)
	if gizmo_just_hit:
		gizmo_just_hit = false
		return
	force_raycast_update()
	if is_colliding():
		var n: Block = get_collider()
		hit.emit(n)
	else:
		miss.emit()

func gizmo_clicked() -> void:
	gizmo_just_hit = true
