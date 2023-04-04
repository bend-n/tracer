extends PanelContainer
class_name TrackEditor

@export var group: ButtonGroup

enum Mode { Select, Move, Rotate, Scale }
var mode: Mode
var selected: Array[TrackObject]:
	set(s):
		if s != selected:
			for b in selected: # easier than finding the items that are not in selected but are in s
				b.live_node.un_highlight()
			selected = s
			for b in selected:
				b.live_node.highlight()
			make_gizmo.emit(mode)
			selection_changed.emit(selected)
var snapping := true
var objects: Array[TrackObject] = []
var history := UndoRedo.new()
signal make_gizmo(mode: Mode)
signal selection_changed(objects: Array[TrackObject])

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
	var new_selected: Array[TrackObject] = []
	new_selected.resize(colls.size())
	for i in len(colls):
		new_selected[i] = tobj_from_node(colls[i])
	selected = new_selected

func _on_snapping_toggled(button_pressed: bool) -> void:
	snapping = button_pressed

func to_trackdata() -> TrackResource:
	objects = objects.filter(func(o: TrackObject): return is_instance_valid(o.live_node))
	var data := TrackResource.new(objects)
	data.name = n
	return data

func _on_item_created(object: TrackObject) -> void:
	objects.append(object)

var n: String
func _on_propertys_name_changed(p_name: String) -> void:
	n = p_name

func tobj_from_node(node: Block) -> TrackObject:
	for o in objects:
		if o.live_node == node:
			return o
	return null

func _on_delete_pressed() -> void:
	selected = []

func _on_remove_tobj(tobj: TrackObject) -> void:
	objects.erase(tobj)
