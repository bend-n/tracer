extends SubViewport
class_name EditorViewport

@onready var editor: TrackEditor = owner

const map = {
	TrackEditor.Mode.Select: preload("res://addons/@bendn/gizmo3d/selection_marker.tscn"),
	TrackEditor.Mode.Move: preload("res://addons/@bendn/gizmo3d/translate/translate.tscn"),
	TrackEditor.Mode.Scale: preload("res://addons/@bendn/gizmo3d/scale/scale.tscn"),
	TrackEditor.Mode.Rotate: preload("res://addons/@bendn/gizmo3d/rotation/rotation.tscn"),
}

var current: Gizmo
var gizmo_holder := Node3D.new()

var original_gh_p: Vector3
var original_scales: PackedVector3Array = []
var original_transforms: Array[Transform3D] = []

func _ready() -> void:
	add_child(gizmo_holder)

func _position_gizmo_holder() -> void:
	var sum := Vector3.ZERO
	for block in editor.selected:
		sum += block.live_node.global_position
	gizmo_holder.global_position = sum / len(editor.selected)

func _setup_originals() -> void:
	original_transforms.resize(len(editor.selected))
	original_scales.resize(len(editor.selected))
	for i in len(editor.selected):
		var n := editor.selected[i].live_node
		original_transforms[i] = n.global_transform
		original_scales[i] = n.scale
		original_gh_p = gizmo_holder.global_position

func update_gizmo(mode: TrackEditor.Mode) -> void:
	if current != null:
		current.queue_free()
		current = null
		original_transforms.clear()
		original_scales.clear()
	match mode:
		_:
			if editor.selected.size() == 0:
				return
			current = map[mode].instantiate()
			_position_gizmo_holder()
			gizmo_holder.add_child(current)
			_setup_originals()
			current.finalize.connect(_gizmo_finalize)
			current.displaced.connect(_gizmo_displace)
			current.scaled.connect(_gizmo_scale)
			current.rotated.connect(_gizmo_rotate)
			current.clicked.connect(%mousecast.gizmo_clicked)

func snap(v: Vector3, step: Vector3 = Globals.SNAP) -> Vector3:
	return v.snapped(step) if editor.snapping else v

func _gizmo_displace(offset: Vector3):
	const prop := &"global_position"
	editor.history.create_action("move %d nodes" % editor.selected.size(), UndoRedo.MERGE_ENDS)
	for i in len(editor.selected):
		var n := editor.selected[i].live_node
		editor.history.add_do_property(n, prop, snap(original_transforms[i].origin + offset))
		editor.history.add_undo_property(n, prop, original_transforms[i].origin)
	editor.history.add_do_property(gizmo_holder, prop, original_gh_p + snap(offset))
	editor.history.add_undo_property(gizmo_holder, prop, original_gh_p)
	editor.history.commit_action()

func _gizmo_scale(change: Vector3):
	const prop := &"scale"
	editor.history.create_action("scale %d nodes" % editor.selected.size(), UndoRedo.MERGE_ENDS)
	for i in len(editor.selected):
		var n := editor.selected[i].live_node
		var scl := snap(original_scales[i] + change, Vector3.ONE)
		if scl.x <= 0 || scl.y <= 0: # pls no flip
			scl = Vector3.ONE
		editor.history.add_do_property(n, prop, scl)
		editor.history.add_undo_property(n, prop, original_scales[i])
	editor.history.commit_action()

func _gizmo_rotate(change: Vector3):
	const prop := &"global_transform"
	editor.history.create_action("rotate %d nodes" % editor.selected.size(), UndoRedo.MERGE_ENDS)
	for i in len(editor.selected):
		var n := editor.selected[i].live_node
		var rotation := Transform3D(Basis.from_euler(change), Vector3())
		editor.history.add_do_property(
			n,
			prop,
			(rotation * original_transforms[i].translated(-original_gh_p)).translated(original_gh_p)
		)
		editor.history.add_undo_property(n, prop, original_transforms[i])
	editor.history.commit_action()

func _gizmo_finalize():
	for i in len(editor.selected):
		var n := editor.selected[i].live_node
		original_scales[i] = n.scale
		original_transforms[i] = n.global_transform
	original_gh_p = gizmo_holder.global_position

func _on_remove_tobj() -> void:
	if current != null:
		current.queue_free()
		current = null
