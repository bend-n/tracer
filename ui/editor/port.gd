extends SubViewport
class_name EditorViewport

@onready var editor: TrackEditor = owner

const map = {
	TrackEditor.Mode.Select: preload("res://ui/editor/gizmos/selection_marker.tscn"),
	TrackEditor.Mode.Move: preload("res://ui/editor/gizmos/translate/translate.tscn"),
	TrackEditor.Mode.Scale: preload("res://ui/editor/gizmos/scale/scale.tscn")
}

var current: Gizmo
var gizmo_holder := Node3D.new()

var original_gh_p: Vector3
var original_positions: PackedVector3Array = []
var original_rotations: PackedVector3Array = []
var original_scales: PackedVector3Array = []

func _ready() -> void:
	add_child(gizmo_holder)

func _position_gizmo_holder() -> void:
	var sum := Vector3.ZERO
	for block in editor.selected:
		sum += block.global_position
	gizmo_holder.global_position = sum / len(editor.selected)

func _setup_originals() -> void:
	original_positions.resize(len(editor.selected))
	original_rotations.resize(len(editor.selected))
	original_scales.resize(len(editor.selected))
	for i in len(editor.selected):
		original_positions[i] = (editor.selected[i].global_position)
		original_rotations[i] = (editor.selected[i].global_rotation)
		original_scales[i] = (editor.selected[i].scale)
		original_gh_p = gizmo_holder.global_position

func update_gizmo(mode: TrackEditor.Mode) -> void:
	if current != null:
		current.queue_free()
		current = null
		original_positions.clear()
		original_rotations.clear()
		original_scales.clear()
	match mode:
		_:
			if editor.selected.size() == 0:
				return
			current = map[mode].instantiate()
			_position_gizmo_holder()
			gizmo_holder.add_child(current)
			current.update_scale()
			_setup_originals()
			current.finalize.connect(_gizmo_finalize) # trust me this is much easier to read than lambdas
			current.displaced.connect(_gizmo_displace)
			current.scaled.connect(_gizmo_scale)
			current.rotated.connect(_gizmo_rotate)
			current.clicked.connect(%mousecast.gizmo_clicked)

func _gizmo_displace(offset: Vector3):
	const prop := &"global_position"
	editor.history.create_action("move %d nodes" % editor.selected.size(), UndoRedo.MERGE_ENDS)
	for i in len(editor.selected):
		editor.history.add_do_property(
			editor.selected[i], prop, original_positions[i] + offset
		)
		editor.history.add_undo_property(
			editor.selected[i], prop, original_positions[i]
		)
	editor.history.add_do_property(gizmo_holder, prop, original_gh_p + offset)
	editor.history.add_undo_property(gizmo_holder, prop, original_gh_p)
	editor.history.commit_action()

func _gizmo_scale(change: Vector3):
	const prop := &"scale"
	editor.history.create_action("scale %d nodes" % editor.selected.size(), UndoRedo.MERGE_ENDS)
	for i in len(editor.selected):
		editor.history.add_do_property(
			editor.selected[i], prop, original_scales[i] + change
		)
		editor.history.add_undo_property(
			editor.selected[i], prop, original_scales[i]
		)
	editor.history.commit_action()

func _gizmo_rotate(change: Vector3):
	const prop := &"global_rotation"
	editor.history.create_action("rotate %d nodes" % editor.selected.size(), UndoRedo.MERGE_ENDS)
	for i in len(editor.selected):
		editor.history.add_do_property(
			editor.selected[i], prop, original_rotations[i] + change
		)
		editor.history.add_undo_property(
			editor.selected[i], prop, original_rotations[i]
		)
	editor.history.commit_action()

func _gizmo_finalize():
	for i in len(editor.selected):
		var o := editor.selected[i]
		original_positions[i] = o.global_position
		original_scales[i] = o.scale
		original_rotations[i] = o.global_rotation
	original_gh_p = gizmo_holder.global_position
	print("set gizmo holder p to %s" % original_gh_p)

func _on_snapping_toggled(button_pressed: bool) -> void:
	if current != null:
		current.snapping = button_pressed

func _on_remove_tobj() -> void:
	if current != null:
		current.queue_free()
		current = null
