extends PanelContainer
class_name TrackEditor

@export var group: ButtonGroup
@onready var brush := %brush

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
var track: TrackResource
var sun: DirectionalLight3D
signal make_gizmo(mode: Mode)
signal selection_changed(objects: Array[TrackObject])

const loader := preload("res://scenes/track.tscn")

func _ready() -> void:
	track = Globals.editing if Globals.editing else TrackResource.new([])
	var l: TrackLoader = loader.instantiate()
	l.editor = true
	l.track = track
	add_child(l)
	# move over the loaders children
	for c in l.get_children():
		l.remove_child(c)
		%port.add_child(c)
		if c is DirectionalLight3D:
			sun = c
	# the loader has loaded, get rid of it
	l.queue_free()

	objects = track.blocks.duplicate() # duplicate: if not saved, will be lost
	%propertys.name_.text = track.name
	%propertys.laps_.value = track.laps
	%propertys.time_.time = { hour = rot2hour(track.sun_x), minute = 00 }
	%propertys.time_.time_changed.connect(func(t: Dictionary): sun.global_rotation.x = hour2rot(t.hour))
	%cam.global_transform = IntroCam.get_origin(track) # put the camera up high, looking straight down

	if not FileAccess.file_exists(Globals.TRACKS % track.name) and not track.builtin:
		%save.unsaved = true

	group.pressed.connect(pressed)
	tree_exiting.connect(
		func():
			for obj in objects:
				obj.delete_live()
	)

func rot2hour(rot: int) -> int:
	return round(24.0 * float(posmod(90 - rot, 360)) / 360.0)

func hour2rot(hour: int) -> float:
	return (6.0 - hour) / 24.0 * TAU

func pressed(b: Button) -> void:
	mode = Mode[b.name.to_pascal_case()]
	make_gizmo.emit(mode)

func reset_selected() -> void:
	var new: Array[TrackObject] = []
	selected = new

func _on_mousecast_hit(colls: Array[Block]) -> void:
	var new_selected: Array[TrackObject] = []
	new_selected.resize(colls.size())
	var painting: bool = brush.button_pressed and not colls.is_empty()
	if painting:
		history.create_action("paint")
	for i in len(colls):
		new_selected[i] = tobj_from_node(colls[i])
		if painting and colls[i].materials_allowed() & brush.mat:
			history.add_do_method(colls[i].set_mat.bind(brush.mat))
			history.add_undo_method(colls[i].set_mat.bind(colls[i].mat))
		assert(new_selected[i]!=null, "%s was not found" % [colls[i]])
	if not brush.button_pressed:
		selected = new_selected
	if painting:
		history.commit_action()

func _on_snapping_toggled(button_pressed: bool) -> void:
	snapping = button_pressed

func get_trackdata() -> TrackResource:
	objects = objects.filter(func(o: TrackObject): return is_instance_valid(o.live_node))
	track.blocks = objects.duplicate()
	track.name = %propertys.name_.text
	track.laps = %propertys.laps_.value
	track.sun_x = roundi(sun.global_rotation_degrees.x)
	return track

func _on_item_created(object: TrackObject) -> void:
	objects.append(object)
	if object.live_node is Booster:
		for block in objects:
			if block.live_node is Booster:
				block.live_node.sync()
	%thonk.pitch_scale = randf_range(.9, 1.2)
	%thonk.play()

func tobj_from_node(node: Block) -> TrackObject:
	for o in objects:
		if o.live_node == node:
			return o
	return null

func _on_delete_pressed() -> void:
	selected = []

func _on_remove_tobj(tobj: TrackObject) -> void:
	objects.erase(tobj)

func _on_brush_toggled(on: bool) -> void:
	if on:
		var painting: bool = brush.button_pressed and not selected.is_empty()
		if painting:
			history.create_action("paint")
		for o in selected:
			if painting and o.live_node.materials_allowed() & brush.mat:
				history.add_do_method(o.live_node.set_mat.bind(brush.mat))
				history.add_undo_method(o.live_node.set_mat.bind(o.live_node.mat))
		if painting:
			history.commit_action()
		reset_selected()
