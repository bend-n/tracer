extends StaticBody3D
class_name TranslateGizmoHandle
# copied from https://github.com/TinyLegions/runtime-spatial-gizmos/ vaguely

@export var dir: Direction = Direction.NONE
enum Direction { X, Z, Y, RELATIVE, NONE } # relative not implemented
var direction2vector := { Direction.X: Vector3.RIGHT, Direction.Y: Vector3.UP, Direction.Z: Vector3.BACK }
@onready var drag_direction: Vector3 = direction2vector[dir]

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
		var dir := cam.project_ray_normal(mp)
		var intersection_of_movement_point = click_plane.intersects_ray(from, dir)
		if intersection_of_movement_point == null:
			# dont move if its exactly parallel to plane
			return
		var dist = intersection_of_movement_point - clicked_position
		var displacement: Vector3 = dist.project(drag_direction)
		get_parent().object.global_transform = original_transform
		get_parent().object.translate_object_local(displacement)

func _ready() -> void:
	input_event.connect(click)

func click(camera: Camera3D, event: InputEvent, click_position: Vector3, _click_normal: Vector3, _shape_idx: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		dragged = true
		var mp := get_viewport().get_mouse_position()
		var vertical_vector = camera.project_ray_normal(mp).normalized().cross(drag_direction)
		var plane_normal := drag_direction.cross(vertical_vector)
		var distance := Plane(plane_normal, 0).distance_to(click_position)
		click_plane = Plane(plane_normal, distance)

		clicked_position = click_position
		original_transform = get_parent().object.global_transform

