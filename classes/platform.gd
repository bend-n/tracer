@tool
class_name Platform3D
extends Block

@export var mesh: MeshInstance3D

var west_wall_scene: PackedScene
var east_wall_scene: PackedScene
var south_wall_scene: PackedScene
var north_wall_scene: PackedScene

func wall_scenes() -> Dictionary:
	return {
		WALL_W: west_wall_scene,
		WALL_E: east_wall_scene,
		WALL_S: south_wall_scene,
		WALL_N: north_wall_scene,
	}

func wall_transforms() -> Dictionary:
	return {
		WALL_W: west_wall_transform,
		WALL_E: east_wall_transform,
		WALL_S: south_wall_transform,
		WALL_N: north_wall_transform,
	}

var west_wall_transform: Transform3D = Transform3D(Basis(), Vector3()):
	set(wt):
		west_wall_transform = wt
		if is_instance_valid(walls[WALL_W]):
			walls[WALL_W].global_transform = wt
var east_wall_transform: Transform3D = Transform3D(Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, -1), Vector3()):
	set(wt):
		east_wall_transform = wt
		if is_instance_valid(walls[WALL_E]):
			walls[WALL_E].global_transform = wt
var south_wall_transform: Transform3D = Transform3D(Vector3(0, 0, -1), Vector3(0, 1, 0), Vector3(1, 0, 0), Vector3()):
	set(wt):
		south_wall_transform = wt
		if is_instance_valid(walls[WALL_S]):
			walls[WALL_S].global_transform = wt
var north_wall_transform: Transform3D = Transform3D(Vector3(0, 0, 1), Vector3(0, 1, 0), Vector3(-1, 0, 0), Vector3()):
	set(wt):
		north_wall_transform = wt
		if is_instance_valid(walls[WALL_N]):
			walls[WALL_N].global_transform = wt

@export_flags("West", "East", "South", "North") var wall_mode := WALL_W | WALL_E | WALL_S | WALL_N:
	set(wm):
		wall_mode = wm
		notify_property_list_changed()

@export_flags("Test west", "Test east", "Test south", "Test north") var tests = 0:
	set(v):
		tests = v if v else 0
		for wall in ITER:
			if has_walls(wall, true) and not tests & wall:
				remove_walls(wall, true)
			elif tests & wall:
				make_walls(wall, true)

func _get_property_list() -> Array:
	var west_usage := PROPERTY_USAGE_DEFAULT if wall_mode & WALL_W else PROPERTY_USAGE_NO_EDITOR
	var east_usage := PROPERTY_USAGE_DEFAULT if wall_mode & WALL_E else PROPERTY_USAGE_NO_EDITOR
	var north_usage := PROPERTY_USAGE_DEFAULT if wall_mode & WALL_N else PROPERTY_USAGE_NO_EDITOR
	var south_usage := PROPERTY_USAGE_DEFAULT if wall_mode & WALL_S else PROPERTY_USAGE_NO_EDITOR
	return [
		{ "name": "west_wall_scene", "type": TYPE_OBJECT, "usage": west_usage, "hint": PROPERTY_HINT_RESOURCE_TYPE, "hint_string": "PackedScene" },
		{ "name": "west_wall_transform", "type": TYPE_TRANSFORM3D, "usage": west_usage },
		{ "name": "east_wall_scene", "type": TYPE_OBJECT, "usage": east_usage, "hint": PROPERTY_HINT_RESOURCE_TYPE, "hint_string": "PackedScene" },
		{ "name": "east_wall_transform", "type": TYPE_TRANSFORM3D, "usage": east_usage },
		{ "name": "north_wall_scene", "type": TYPE_OBJECT, "usage": north_usage, "hint": PROPERTY_HINT_RESOURCE_TYPE, "hint_string": "PackedScene" },
		{ "name": "north_wall_transform", "type": TYPE_TRANSFORM3D, "usage": north_usage },
		{ "name": "south_wall_scene", "type": TYPE_OBJECT, "usage": south_usage, "hint": PROPERTY_HINT_RESOURCE_TYPE, "hint_string": "PackedScene" },
		{ "name": "south_wall_transform", "type": TYPE_TRANSFORM3D, "usage": south_usage },
	]

# virtual wall functions
func make_walls(w: int, singular := false) -> void:
	for wall in walls:
		if w & wall:
			if is_instance_valid(walls[wall]):
				push_error("wall exists!")
				return
			var node: Wall = wall_scenes()[wall].instantiate()
			node.global_transform = wall_transforms()[wall]
			add_child(node)
			walls[wall] = node
			if singular:
				return
func get_wall_mode() -> int: return wall_mode
func get_aabb() -> AABB: return mesh.get_aabb()
# virtual mat functions
func materials_allowed() -> int: return 1|2|4
func default_mat() -> int: return 1
func set_mat(p_mat: int) -> void: mat = p_mat; reset_map()
# virtual editor functions
func un_highlight(): reset_map()
func highlight() -> void: mesh.set_surface_override_material(0, MatMap.get_highlight(mat))
# utility functions
func reset_map():
	mesh.set_surface_override_material(0, MatMap.map[mat])

