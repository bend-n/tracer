@tool
extends StaticBody3D
class_name Block

## A Block that goes in a [TrackObject] to be placed by a [TrackLoader].

## [code]true[/code] if this block in the editor.
var editor := false

## The left(z-) wall for this block.
var left_wall: Wall = null
## The right(z+) wall for this block.
var right_wall: Wall = null

const WALL_MODE_LEFT = 1
const WALL_MODE_RIGHT = 2

func _ready() -> void:
	if editor:
		collision_layer = Globals.DEFAULT_EDITOR_LAYER

# override functions

## Gets the [AABB] of this block.
func get_aabb() -> AABB: return AABB()
## Makes this block visually highlighted. See also [method un_highlight].
func highlight() -> void: pass
## Reverses [method highlight].
func un_highlight() -> void: pass
## Get the wall mode.
## Returns a flag that can container [const WALl_MODE_LEFT] and [const WALL_MODE_RIGHT]
func get_wall_mode() -> int: return 0
func make_left_wall() -> void: pass
func remove_left_wall() -> void: left_wall.queue_free()
func make_right_wall() -> void: pass
func has_left_wall() -> bool: return false
func has_right_wall() -> bool: return false
func remove_right_wall() -> void: right_wall.queue_free()
## Can this block be painted? (TODO)
func can_theme() -> bool: return false
func get_mats() -> Array[BaseMaterial3D]: return []
func set_mats(_mats: Array[BaseMaterial3D]) -> void: pass
