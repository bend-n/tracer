extends SubViewportContainer

@onready var history: UndoRedo = owner.history
var block_preview := { link = null, node = null }

signal created(object: TrackObject)
signal remove_tobj(tobj: TrackObject)

func _can_drop_data(at_position: Vector2, data) -> bool:
	if not data is WeakLink:
		return false
	var link: WeakLink = data
	var transform := Transform3D(Basis(), Utils.snap_v(10, 5, 10, %cam.project_position(at_position, 50)))
	if is_instance_valid(block_preview.node):
		if block_preview.link == link:
			block_preview.node.global_transform = transform
			return true
		block_preview.node.queue_free()
	block_preview.node = link.scene.instantiate() as Block
	block_preview.node.global_transform = transform
	block_preview.node.editor = true
	block_preview.link = link
	add_child(block_preview.node)
	return true

func _on_mouse_exited() -> void:
	if is_instance_valid(block_preview.node):
		block_preview.link = null
		block_preview.node.queue_free()

func _drop_data(at_position: Vector2, data) -> void:
	var link: WeakLink = data
	match link.type:
		WeakLink.Type.Scene:
			var node: Block = block_preview.node # initialized by [method _can_drop_data]
			block_preview.node = null
			block_preview.link = null
			remove_child(node)
			var obj := TrackObject.new(link.scene, node, link)
			history.create_action("add block");
			history.add_do_method(add_obj.bind(obj, node))
			history.add_do_reference(node)
			history.add_undo_method(remove_obj.bind(obj, node))
			var origin: Vector3 = Utils.snap_v(10, 5, 10, %cam.project_position(at_position, 50))
			history.add_do_property(node, &"global_transform", Transform3D(Basis(), origin))
			history.commit_action()

func add_obj(o: TrackObject, n: Node):
	%port.add_child(n)
	created.emit(o)

func remove_obj(o: TrackObject, n: Node):
	remove_tobj.emit(o)
	%port.remove_child(n)
