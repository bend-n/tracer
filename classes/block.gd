@tool
extends StaticBody3D
class_name Block

## A Block that goes in a [TrackObject] to be placed by a [TrackLoader].

## [code]true[/code] if this block in the editor.
var editor := false
## [code]true[/code] if this block is being photographed.
var making_thumbnail := false

## A dictionary storing the walls.
## Dictionary[int, Wall]
var walls := {
	WALL_W: null, # z-
	WALL_E: null, # z+
	WALL_S: null, # x-
	WALL_N: null, # x+
}

const WALL_W := 1
const WALL_E := 2
const WALL_S := 4
const WALL_N := 8
const STRING := {
	WALL_W: "west",
	WALL_E: "east",
	WALL_S: "south",
	WALL_N: "north",
}
const ITER := [WALL_W, WALL_E, WALL_S, WALL_N]

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if editor:
		collision_layer = Globals.DEFAULT_EDITOR_LAYER
	if not making_thumbnail:
		var cam := get_node_or_null(^"camera")
		if cam:
			cam.queue_free()
	input_ray_pickable = false

# helpers

func has_wall(w: int) -> bool: return has_walls(w, true) & w
func remove_wall(w: int) -> void: remove_walls(w, true)
func make_wall(w: int) -> void: make_walls(w, true)

# virtual functions

## Gets the [AABB] of this block.
func get_aabb() -> AABB: return AABB()
## Makes this block visually highlighted. See also [method un_highlight].
func highlight() -> void: pass
## Reverses [method highlight].
func un_highlight() -> void: pass
## Get the wall mode.
## Returns a flag. see [const WALL_W].
func get_wall_mode() -> int: return 0
func make_walls(_w: int, _singular := false) -> void: pass
func remove_walls(w: int, singular := false) -> void:
	for wall in walls:
		if w & wall:
			if not is_instance_valid(walls[wall]):
				push_error("wall doesnt exist!")
				return
			walls[wall].queue_free()
			if singular:
				return
func has_walls(w := WALL_W | WALL_E | WALL_N | WALL_S, singular := false) -> int:
	var has := 0
	for wall in walls:
		if w & wall:
			if is_instance_valid(walls[wall]):
				if singular:
					return wall
				has |= wall
			elif singular:
				return 0
	return has
## Can this block be painted? (TODO)
func can_theme() -> bool: return false
func get_mats() -> Array[BaseMaterial3D]: return []
func set_mats(_mats: Array[BaseMaterial3D]) -> void: pass
