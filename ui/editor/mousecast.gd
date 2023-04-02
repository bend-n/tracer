extends RayCast3D
class_name MouseCast

@onready var v := get_viewport()
@onready var drag_area: ColorRect = $area
@onready var c := v.get_camera_3d()
var gizmo_just_hit := false
var viewport_just_dropped := false
var cast_ray := false
var start = null
const depth := 2000.0

signal miss
signal hit(coll: Block)

func position_to(p: Vector2):
	global_position = c.project_ray_origin(p)
	target_position = c.project_ray_normal(p) * depth

func _input(e: InputEvent) -> void:
	if not e is InputEventMouse:
		return
	if e is InputEventMouseButton:
		if e.button_index == MOUSE_BUTTON_LEFT and start == null and e.is_pressed():
			drag_area.show()
			start = e.position
			return
		start = null
		drag_area.hide()
		drag_area.size = Vector2.ZERO
	elif e is InputEventMouseMotion and start != null:
		var r := Rect2(start, Vector2.ZERO).expand(e.position)
		drag_area.position = r.position
		drag_area.size = r.size

func _physics_process(_delta: float) -> void:
	set_physics_process(false)
	if gizmo_just_hit || viewport_just_dropped:
		gizmo_just_hit = false
		viewport_just_dropped = false
		return
	force_raycast_update()
	if is_colliding():
		var n: Block = get_collider()
		hit.emit(n)
	else:
		miss.emit()

func gizmo_clicked() -> void:
	gizmo_just_hit = true

func _on_view_created() -> void:
	viewport_just_dropped = true
