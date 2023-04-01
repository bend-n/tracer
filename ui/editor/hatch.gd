extends SubViewportContainer

@onready var history: UndoRedo = owner.history

signal created(object: TrackObject)
signal remove_tobj(tobj: TrackObject)

func _can_drop_data(_p: Vector2, data) -> bool:
	return data is WeakLink

func _drop_data(at_position: Vector2, data) -> void:
	var link: WeakLink = data
	match link.type:
		WeakLink.Type.Scene:
			var scn := link.scene
			var node := scn.instantiate() as Block
			if node.get_script() != null:
				node.editor = true
			var obj := TrackObject.new(scn, node)
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
