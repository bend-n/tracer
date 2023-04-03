extends PanelContainer
class_name TrackEditor

@export var group: ButtonGroup

enum Mode { Select, Move, Rotate, Scale }
var mode: Mode
var selected: Node3D
var snapping := true
var objects: Array[TrackObject] = []
var history := UndoRedo.new()
var selection_parent := Node3D.new()
signal make_gizmo(mode: Mode)

const loader := preload("res://scenes/track.tscn")

func _ready() -> void:
	selection_parent.name = "selection parent"
	%port.add_child(selection_parent)
	var data := Globals.editing if Globals.editing else TrackResource.new([])
	var l: TrackLoader = loader.instantiate()
	l.editor = true
	l.track = data
	add_child(l)
	# move over the loaders children
	for c in l.get_children():
		l.remove_child(c)
		%port.add_child(c)
	# the loader has loaded, get rid of it
	l.queue_free()
	objects = data.blocks # please be reference
	%propertys.set_n(data.name)
	n = data.name
	%cam.global_transform = IntroCam.get_origin(data) # put the camera up high, looking straight down

	if not FileAccess.file_exists(Globals.TRACKS % data.name):
		%save.unsaved = true

	group.pressed.connect(pressed)

func pressed(b: Button) -> void:
	mode = Mode[b.name.to_pascal_case()]
	make_gizmo.emit(mode)

func _on_mousecast_hit(colls: Array[Block]) -> void:
	if colls.size() == 0:
		selected = null
	elif colls.size() == 1:
		if selected == colls[0]:
			return
		selected = colls[0]
	elif colls.size() > 1:
		var v: EditorViewport = %port
		for c in selection_parent.get_children(): # clear the parent
			selection_parent.remove_child(c)
			v.add_child(c)
		for coll in colls: # set up the parent
			v.remove_child(coll)
			selection_parent.add_child(coll)
		selected = selection_parent
	make_gizmo.emit(mode)

func _on_snapping_toggled(button_pressed: bool) -> void:
	snapping = button_pressed

func to_trackdata() -> TrackResource:
	objects = objects.filter(func(o: TrackObject): return is_instance_valid(o.live_node))
	var data := TrackResource.new(objects)
	data.name = n
	return data

func _on_item_created(object: TrackObject) -> void:
	objects.append(object)
	selected = object.live_node
	make_gizmo.emit(mode)

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

func _on_remove_tobj(tobj: TrackObject) -> void:
	objects.erase(tobj)
