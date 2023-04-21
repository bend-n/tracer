extends Control
class_name WallTool

var initializing := false
var blocks: Array[Block]
@export var editor: TrackEditor
@onready var hist: UndoRedo = editor.history
@onready var buttons := {
	Block.WALL_W: %west,
	Block.WALL_E: %east,
	Block.WALL_S: %south,
	Block.WALL_N: %north,
}

func _ready() -> void:
	reset()

func toggle(on: bool, wall: int) -> void:
	if initializing: return
	hist.create_action("set %s wall on %d nodes" % [Block.STRING[wall], len(blocks)])
	for block in blocks:
		if block.get_wall_mode() & wall:
			if on and not block.has_wall(wall):
				hist.add_do_method(block.make_wall.bind(wall))
				hist.add_undo_method(block.make_wall.bind(wall))
			elif block.has_wall(wall):
				hist.add_do_method(block.remove_wall.bind(wall))
				hist.add_undo_method(block.make_wall.bind(wall))
	hist.commit_action()

func reset():
	visible = false
	for button in buttons.values():
		button.disabled = true
	blocks.clear()

func _on_track_editor_selection_changed(p_nodes: Array[TrackObject]) -> void:
	reset()
	initializing = true
	var has_map := { Block.WALL_W: 0, Block.WALL_E: 0, Block.WALL_N: 0, Block.WALL_S: 0 }
	for node in p_nodes:
		var wm := node.live_node.get_wall_mode()
		if wm == 0:
			continue
		for wall in buttons:
			if wm & wall:
				buttons[wall].disabled = false
				visible = true
				if node.live_node.has_wall(wall):
					has_map[wall] += 1
		blocks.append(node.live_node)
	var half_or_none := roundi(blocks.size()/2.0) if blocks.size()>1 else 0
	for wall in buttons:
		buttons[wall].button_pressed = has_map[wall] > half_or_none
	initializing = false
