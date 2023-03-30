extends PanelContainer
class_name TrackEditor

@export var group: ButtonGroup

enum Mode { Select, Move, Rotate, Scale }
var mode: Mode
var selected: Node3D
var snapping := true
var objects: Array[TrackObject] = []
var history := UndoRedo.new()
signal make_gizmo(mode: Mode)

const loader := preload("res://scenes/track.tscn")

func _ready() -> void:
	var data := Globals.editing if Globals.editing else TrackResource.new([])
	var l: TrackLoader = loader.instantiate()
	l.editor = true
	l.track = data
	add_child(l)
	# move over the loaders children
	for c in l.get_children():
		l.remove_child(c)
		%port.add_child(c)
		if c is Floor:
			c.input_event.connect(%items._on_floor_input_event)
		elif not c is WorldEnvironment and not c is DirectionalLight3D:
			var collider: PhysicsBody3D = c if c is PhysicsBody3D else c.collision
			collider.input_event.connect(%items.node_input.bind(c))
	# the loader has loaded, get rid of it
	l.queue_free()
	objects = data.blocks # please be reference
	%propertys.set_n(data.name)
	n = data.name
	%cam.global_transform = IntroCam.get_origin(data) # put the camera up high, looking straight down

	if not FileAccess.file_exists(Globals.TRACKS % data.name):
		%save.set_unsaved()

	group.pressed.connect(
		func pressed(b: Button) -> void:
			mode = Mode[b.name.to_pascal_case()]
			make_gizmo.emit(mode)
	)

func _on_selected_node(node: Node3D) -> void:
	if selected == node:
		return
	selected = node
	print("object: %s selected! mode: %s" % [node, mode])
	make_gizmo.emit(mode)

func _on_snapping_toggled(button_pressed: bool) -> void:
	snapping = button_pressed

func to_trackdata() -> TrackResource:
	objects = objects.filter(func(o: TrackObject): return is_instance_valid(o.live_node))
	var data := TrackResource.new(objects)
	data.name = n
	return data

func _on_items_created(object: TrackObject) -> void:
	objects.append(object)

var n: String
func _on_propertys_name_changed(p_name: String) -> void:
	n = p_name

func tobj_from_node(node: Node) -> TrackObject:
	for o in objects:
		if o.live_node == node:
			return o
	return null

func _on_delete_pressed() -> void:
	selected = null

func _on_items_remove_tobj(tobj: TrackObject) -> void:
	objects.erase(tobj)
