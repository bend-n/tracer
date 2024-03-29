extends RayCast3D
class_name MouseCast

@onready var v := get_viewport()
@onready var drag_area: ColorRect = $area
@onready var c := v.get_camera_3d()
@onready var editor: TrackEditor = owner
var gizmo_just_hit := false
var viewport_just_dropped := false
var cast_ray := false
var start = null
const depth := 4000.0

signal hit(colls: Array[Block])

func position_to(p: Vector2):
	global_position = c.project_ray_origin(p)
	target_position = c.project_ray_normal(p) * depth

func _physics_process(_delta: float) -> void:
	if gizmo_just_hit || viewport_just_dropped:
		gizmo_just_hit = false
		viewport_just_dropped = false
		start = null
		drag_area.hide()
		drag_area.size = Vector2.ZERO
		return
	if (
		start == null # not already dragging
		and Input.is_action_just_pressed("click") # just clicked
		and Rect2(Vector2.ZERO, get_viewport().size).has_point(get_viewport().get_mouse_position()) # mouse is over viewport
	):
		start = get_viewport().get_mouse_position()
		drag_area.show()
	elif Input.is_action_just_released("click") and start != null:
		var selection: Array[Block] = []
		var r := Rect2(start, Vector2.ZERO).expand(get_viewport().get_mouse_position())
		start = null
		drag_area.hide()
		drag_area.size = Vector2.ZERO
		if r.size.length_squared() < 1000:
			position_to(r.get_center())
			force_raycast_update()
			if is_colliding() and get_collider() != null:
				selection.append(get_collider())
			hit.emit(selection)
			return
		for obj in editor.objects:
			var origin := obj.live_node.transform.origin
			if c.is_position_behind(origin) || c.global_position.distance_squared_to(origin) > 40000:
				continue
			var point := c.unproject_position(origin)
			if r.has_point(point):
				selection.append(obj.live_node)
		hit.emit(selection)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and start != null:
		var r := Rect2(start, Vector2.ZERO).expand(get_viewport().get_mouse_position())
		drag_area.position = r.position
		drag_area.size = r.size

func gizmo_clicked() -> void:
	gizmo_just_hit = true

func _on_view_created() -> void:
	viewport_just_dropped = true
