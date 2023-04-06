extends SubViewportContainer

@onready var history: UndoRedo = owner.history

signal created(object: TrackObject)
signal remove_tobj(tobj: TrackObject)

func _can_drop_data(_at_position: Vector2, data) -> bool:
	return (
		data is Array
		and data.size() == 2
		and data[0] is Array[TrackObject]
		and data[1] is PackedVector3Array
		and data[0].size() == data[1].size()
	) or data is Array[TrackObject]


func _drop_data(at_position: Vector2, data) -> void:
	var objs: Array[TrackObject]
	var offsets: PackedVector3Array = []
	var offsets_unset := false
	if (
		data is Array
		and data.size() == 2
		and data[0] is Array[TrackObject]
		and data[1] is PackedVector3Array
		and data[0].size() == data[1].size()
	):
		objs = data[0].duplicate()
		offsets = data[1]
	elif data is Array[TrackObject]:
		objs = data.duplicate()
		offsets_unset = true
	history.create_action("add blocks");
	for i in len(objs):
		var obj := objs[i]
		var node: Block = obj.create(true)
		var projected: Vector3 = %cam.project_position(at_position, 50)
		var pos := (projected + offsets[i] if not offsets_unset else projected).snapped(Globals.SNAP)
		obj.set_live(node)
		history.add_do_method(add_obj.bind(obj, pos))
		history.add_undo_method(remove_obj.bind(obj))
		history.add_do_reference(node)
	history.commit_action()

func add_obj(o: TrackObject, pos := Vector3.ZERO):
	%port.add_child(o.live_node)
	o.live_node.global_position = pos
	created.emit(o)

func remove_obj(o: TrackObject):
	remove_tobj.emit(o)
	%port.remove_child(o.live_node)
