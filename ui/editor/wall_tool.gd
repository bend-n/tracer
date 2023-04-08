extends Control
class_name WallTool

var initializing := false
var blocks: Array[Block]
@export var editor: TrackEditor
@onready var hist: UndoRedo = editor.history

func _ready() -> void:
	reset()

func _on_left_toggled(button_pressed: bool) -> void:
	if initializing: return
	hist.create_action("set left wall on %d nodes" % len(blocks))
	for block in blocks:
		if block.get_wall_mode() & Block.WALL_MODE_LEFT:
			if button_pressed and not block.has_left_wall():
				hist.add_do_method(block.make_left_wall)
				hist.add_undo_method(block.remove_left_wall)
			elif block.has_left_wall():
				hist.add_do_method(block.remove_left_wall)
				hist.add_undo_method(block.make_left_wall)
	hist.commit_action()

func _on_right_toggled(button_pressed: bool) -> void:
	if initializing: return
	hist.create_action("set right wall on %d nodes" % len(blocks))
	for block in blocks:
		if block.get_wall_mode() & Block.WALL_MODE_RIGHT:
			if button_pressed and not block.has_right_wall():
				hist.add_do_method(block.make_right_wall)
				hist.add_undo_method(block.remove_right_wall)
			elif block.has_right_wall():
				hist.add_do_method(block.remove_right_wall)
				hist.add_undo_method(block.make_right_wall)
	hist.commit_action()

func reset():
	visible = false
	%left.disabled = true
	%right.disabled = true
	blocks.clear()

func _on_track_editor_selection_changed(p_nodes: Array[TrackObject]) -> void:
	reset()
	initializing = true
	var has_map := { Block.WALL_MODE_LEFT: 0, Block.WALL_MODE_RIGHT: 0 }
	for node in p_nodes:
		var wm := node.live_node.get_wall_mode()
		if wm == 0:
			continue
		if wm & Block.WALL_MODE_LEFT:
			%left.disabled = false
			visible = true
			if node.live_node.has_left_wall():
				has_map[Block.WALL_MODE_LEFT] += 1
		if wm & Block.WALL_MODE_RIGHT:
			%right.disabled = false
			visible = true
			if node.live_node.has_right_wall():
				has_map[Block.WALL_MODE_RIGHT] += 1
		blocks.append(node.live_node)
	var half_or_none := roundi(blocks.size()/2.0) if blocks.size()>1 else 0
	%left.button_pressed = has_map[Block.WALL_MODE_LEFT] > half_or_none
	%right.button_pressed = has_map[Block.WALL_MODE_RIGHT] > half_or_none
	initializing = false
