extends SubViewport

@onready var editor: TrackEditor = owner

const map = {
	TrackEditor.Mode.Select: preload("res://ui/editor/gizmos/selection_marker.tscn"),
	TrackEditor.Mode.Move: preload("res://ui/editor/gizmos/translate/translate.tscn"),
	TrackEditor.Mode.Scale: preload("res://ui/editor/gizmos/scale/scale.tscn")
}

var current: Gizmo
var gizmo_mover: RemoteTransform3D

func update_gizmo(mode: TrackEditor.Mode) -> void:
	if current != null:
		current.queue_free()
		current = null
	if gizmo_mover != null:
		gizmo_mover.queue_free()
		gizmo_mover = null
	match mode:
		_:
			if editor.selected != null:
				current = map[mode].instantiate()
				current.snapping = editor.snapping
				current.path = editor.selected.get_path()
				current.hist = owner.history
				current.clicked.connect($mousecast.gizmo_clicked)
				gizmo_mover = RemoteTransform3D.new()
				gizmo_mover.update_rotation = false
				gizmo_mover.update_scale = false
				gizmo_mover.update_position = true
				add_child(current)
				gizmo_mover.remote_path = current.get_path()
				current.global_position = editor.selected.global_position
				editor.selected.add_child(gizmo_mover)
				current.update_scale()

func _on_snapping_toggled(button_pressed: bool) -> void:
	if current != null:
		current.snapping = button_pressed

func _on_remove_tobj() -> void:
	if current != null:
		current.queue_free()
		current = null
