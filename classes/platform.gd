@tool
extends Block
class_name Platform3D

@export var mesh: MeshInstance3D

const DEFAULT_TRANSFORM := Transform3D(Basis(), Vector3())

var left_wall_scene: PackedScene
var left_wall_transform: Transform3D = DEFAULT_TRANSFORM:
	set(lwt):
		left_wall_transform = lwt
		if is_instance_valid(left_wall):
			left_wall.global_transform = lwt
var right_wall_scene: PackedScene
var right_wall_transform: Transform3D = DEFAULT_TRANSFORM:
	set(rwt):
		right_wall_transform = rwt
		if is_instance_valid(right_wall):
			right_wall.global_transform = rwt

@export_flags("Left Wall", "Right Wall") var wall_mode := WALL_MODE_LEFT | WALL_MODE_RIGHT:
	set(wm):
		wall_mode = wm
		notify_property_list_changed()

var test_left_wall = false:
	set(v):
		if Engine.is_editor_hint():
			test_left_wall = v
			if test_left_wall: make_left_wall()
			elif has_left_wall(): remove_left_wall()
var test_right_wall = false:
	set(v):
		if Engine.is_editor_hint():
			test_right_wall = v
			if v: make_right_wall()
			elif has_right_wall(): remove_right_wall()

func _get_property_list() -> Array:
	var left_usage := PROPERTY_USAGE_DEFAULT if wall_mode & WALL_MODE_LEFT else PROPERTY_USAGE_NO_EDITOR
	var right_usage := PROPERTY_USAGE_DEFAULT if wall_mode & WALL_MODE_RIGHT else PROPERTY_USAGE_NO_EDITOR
	return [
		{ "name": "left_wall_scene", "type": TYPE_OBJECT, "usage": left_usage, "hint": PROPERTY_HINT_RESOURCE_TYPE, "hint_string": "PackedScene" },
		{ "name": "left_wall_transform", "type": TYPE_TRANSFORM3D, "usage": left_usage },
		{ "name": "test_left_wall", "type": TYPE_BOOL, "usage": left_usage },
		{ "name": "right_wall_scene", "type": TYPE_OBJECT, "usage": right_usage, "hint": PROPERTY_HINT_RESOURCE_TYPE, "hint_string": "PackedScene" },
		{ "name": "right_wall_transform", "type": TYPE_TRANSFORM3D, "usage": right_usage },
		{ "name": "test_right_wall", "type": TYPE_BOOL, "usage": right_usage }
	]


func make_left_wall():
	left_wall = left_wall_scene.instantiate()
	if left_wall_transform != DEFAULT_TRANSFORM:
		left_wall.global_transform = left_wall_transform
	add_child(left_wall)

func make_right_wall():
	right_wall = right_wall_scene.instantiate()
	if right_wall_transform != DEFAULT_TRANSFORM:
		right_wall.global_transform = right_wall_transform
	add_child(right_wall)

func get_wall_mode() -> int: return wall_mode
func can_theme() -> bool: return true
func has_left_wall() -> bool: return is_instance_valid(left_wall)
func has_right_wall() -> bool: return is_instance_valid(right_wall)

func un_highlight():
	if !_previous_material:
		push_error("no mat!")
		return
	mesh.set_surface_override_material(0, _previous_material)

var _previous_material: BaseMaterial3D
func highlight() -> void:
	_previous_material = mesh.get_active_material(0)
	mesh.set_surface_override_material(0, MatMap.get_highlight(_previous_material))
