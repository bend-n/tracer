extends Resource
class_name BlockMap

const map := [
	preload("res://assets/blocks/platform_booster.tscn"),
	preload("res://assets/blocks/platform_corner.tscn"),
	preload("res://assets/blocks/platform_depression.tscn"),
	preload("res://assets/blocks/platform_diagonal.tscn"),
	preload("res://assets/blocks/platform_poke.tscn"),
	preload("res://assets/blocks/platform_poke_corner.tscn"),
	preload("res://assets/blocks/platform_ramp.tscn"),
	preload("res://assets/blocks/platform_square.tscn"),
	preload("res://assets/blocks/platform_turn_1x1.tscn"),
	preload("res://assets/blocks/platform_turn_2x2.tscn"),
	preload("res://assets/blocks/platform_turn_3x3.tscn"),
	preload("res://assets/blocks/platform_x.tscn"),
	preload("res://assets/blocks/ring_checkpoint.tscn"),
	preload("res://assets/blocks/ring_finish.tscn"),
	preload("res://assets/blocks/ring_start.tscn"),
	preload("res://assets/blocks/tree.tscn"),
	preload("res://assets/blocks/arrow.tscn")
]

static func find(s: PackedScene):
	return map.find(s)
