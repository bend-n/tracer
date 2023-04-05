extends SubViewportContainer

@onready var history: UndoRedo = owner.history
var block_preview_original_objs: Array[TrackObject]
var block_preview_objects: Array[TrackObject]

signal created(object: TrackObject)
signal remove_tobj(tobj: TrackObject)

func reset_preview():
	for block in block_preview_objects:
		block.live_node.queue_free()
	block_preview_original_objs = [] # dont delete the previous array
	block_preview_objects.clear()

## TODO: do this on the actual preview instead
func _can_drop_data(at_position: Vector2, data) -> bool:
	var blocks: Array[TrackObject]
	var offsets: PackedVector3Array
	var offsets_unset := false
	if (
		data is Array
		and data.size() == 2
		and data[0] is Array[TrackObject]
		and data[1] is PackedVector3Array
		and data[0].size() == data[1].size()
	):
		blocks = data[0]
		offsets = data[1]
	elif data is Array[TrackObject]:
		blocks = data
		offsets_unset = true
	else:
		return false
	var mp: Vector3 = %cam.project_position(at_position, 50)
	if not block_preview_objects.is_empty():
		if block_preview_original_objs == blocks:
			for i in len(block_preview_objects):
				block_preview_objects[i].live_node.global_position = ((offsets[i] + mp) if not offsets_unset else mp).snapped(Globals.SNAP)
			return true
		reset_preview()
	block_preview_original_objs = blocks
	block_preview_objects.resize(len(blocks))
	for i in len(blocks):
		var block: Block = blocks[i].base_scene.instantiate()
		block.editor = true
		var obj := TrackObject.new(blocks[i].base_scene, block, blocks[i].link)
		block_preview_objects[i] = obj
		add_child(block)
		obj.set_live(block)
		obj.live_node.global_position = ((offsets[i] + mp) if not offsets_unset else mp).snapped(Globals.SNAP)
	return true

func _on_mouse_exited() -> void:
	if block_preview_original_objs.size() > 0:
		reset_preview()

func _drop_data(_at_position: Vector2, _data) -> void:
	var objs: Array[TrackObject] = block_preview_objects # initialized by [method _can_drop_data]
	block_preview_original_objs = [] # delete the previous array
	block_preview_objects = []
	history.create_action("add blocks");
	for obj in objs:
		remove_child(obj.live_node)
		var node := obj.live_node
		history.add_do_method(add_obj.bind(obj))
		history.add_do_reference(node)
		history.add_undo_method(remove_obj.bind(obj, node))
	history.commit_action()

func add_obj(o: TrackObject):
	%port.add_child(o.live_node)
	created.emit(o)

func remove_obj(o: TrackObject):
	remove_tobj.emit(o)
	%port.remove_child(o.live_node)
