extends StaticBody3D
class_name TranslateGizmoCenter


#					current_position += editor_viewport.gizmo_camera.global_transform.basis.y * -mouse_delta.y;

#                    current_position += editor_viewport.gizmo_camera.global_transform.basis.x * mouse_delta.x;

var dragged := false
var clicked_position := Vector3.ZERO
var click_plane: Plane
var original_transform: Transform3D

func _process(_delta: float):
	if dragged and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		dragged = false
	if dragged:
		var cam := get_viewport().get_camera_3d()
		var mp := get_viewport().get_mouse_position()

		var from := cam.project_ray_origin(mp)
		var toward := cam.project_ray_normal(mp)
		var intersection_of_movement_point = click_plane.intersects_ray(from, toward)
		if intersection_of_movement_point == null:
			# dont move if its exactly parallel to plane
			return
		var displacement: Vector3 = intersection_of_movement_point - clicked_position
		owner.object.global_transform = original_transform
		owner.object.translate_object_local(displacement)
		if owner.snapping:
			owner.object.global_position = (owner.object.global_position as Vector3).snapped(Vector3.ONE*10)

func _ready() -> void:
	input_event.connect(click)

func click(camera: Camera3D, event: InputEvent, click_position: Vector3, _click_normal: Vector3, _shape_idx: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		dragged = true
		var mp := get_viewport().get_mouse_position()
		var plane_normal := camera.project_ray_normal(mp).normalized()
		var distance := Plane(plane_normal, 0).distance_to(click_position)
		click_plane = Plane(plane_normal, distance)

		clicked_position = click_position
		original_transform = owner.object.global_transform
