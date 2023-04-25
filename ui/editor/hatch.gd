extends SubViewportContainer

@onready var history: UndoRedo = owner.history

signal created(object: TrackObject)
signal remove_tobj(tobj: TrackObject)
signal depth_changed(depth: float)

@export var shift_scrollup: Shortcut
@export var shift_scrolldown: Shortcut


var input_ms: int = 0
var depth: float = 50.0:
	set(d):
		depth = d
		depth_changed.emit(d)

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
		objs = data[0]
		offsets = data[1]
	elif data is Array[TrackObject]:
		objs = data
		offsets_unset = true
	history.create_action("add blocks");
	for i in len(objs):
		var obj := objs[i]
		var node: Block = obj.create(true)
		var projected: Vector3 = %cam.project_position(at_position, depth)
		var pos := (projected + offsets[i] if not offsets_unset else projected).snapped(Globals.SNAP)
		obj.set_live(node)
		history.add_do_method(add_obj.bind(obj, pos))
		history.add_undo_method(remove_obj.bind(obj))
		history.add_do_reference(node)
	history.commit_action()

func add_obj(o: TrackObject, pos = null):
	%port.add_child(o.live_node)
	if pos is Vector3:
		o.live_node.global_position = pos
	created.emit(o)

func remove_obj(o: TrackObject):
	remove_tobj.emit(o)
	%port.remove_child(o.live_node)

func _gui_input(event: InputEvent) -> void:
	var change := func(i: float):
		# debounce
		if Time.get_ticks_msec() - input_ms > 1:
			depth = max(25, depth + i)
			input_ms = Time.get_ticks_msec()
		get_viewport().set_input_as_handled()
	if shift_scrolldown.matches_event(event): change.call(-Globals.SNAP.y)
	elif shift_scrollup.matches_event(event): change.call(Globals.SNAP.y)
