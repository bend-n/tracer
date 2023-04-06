extends Window
class_name WallTool

var blocks: Array[Block]
var hist: UndoRedo

func init(p_nodes: Array[TrackObject], p_hist: UndoRedo) -> void:
	var has_map := { Block.WALL_MODE_LEFT: 0, Block.WALL_MODE_RIGHT: 0 }
	for node in p_nodes:
		var wm := node.live_node.get_wall_mode()
		if wm == 0:
			continue
		if wm & Block.WALL_MODE_LEFT:
			%left.disabled = false
			if node.live_node.has_left_wall():
				has_map[Block.WALL_MODE_LEFT] += 1
		if wm & Block.WALL_MODE_RIGHT:
			%right.disabled = false
			if node.live_node.has_right_wall():
				has_map[Block.WALL_MODE_RIGHT] += 1
		blocks.append(node.live_node)
	if has_map[Block.WALL_MODE_LEFT] > roundi(blocks.size() / 2.0):
		%left.button_pressed = true
	if has_map[Block.WALL_MODE_RIGHT] > roundi(blocks.size() / 2.0):
		%right.button_pressed = true
	hist = p_hist

func _on_left_toggled(button_pressed: bool) -> void:
	hist.create_action("set left wall on %d nodes" % len(blocks))
	for block in blocks:
		if block.get_wall_mode() & Block.WALL_MODE_LEFT:
			if button_pressed:
				hist.add_do_method(block.make_left_wall)
				hist.add_undo_method(block.make_right_wall)
				block.make_left_wall()
			elif block.has_left_wall():
				hist.add_do_method(block.remove_left_wall)
				hist.add_undo_method(block.make_left_wall)
	hist.commit_action()

func _on_right_toggled(button_pressed: bool) -> void:
	hist.create_action("set right wall on %d nodes" % len(blocks))
	for block in blocks:
		if block.get_wall_mode() & Block.WALL_MODE_RIGHT:
			if button_pressed:
				hist.add_do_method(block.make_right_wall)
				hist.add_undo_method(block.remove_right_wall)
			elif block.has_right_wall():
				hist.add_do_method(block.remove_right_wall)
				hist.add_undo_method(block.make_right_wall)
	hist.commit_action()

