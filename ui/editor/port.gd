extends SubViewport

@export var editor: TrackEditor

const map = {
	TrackEditor.Mode.Select: preload("res://ui/editor/gizmos/selection_marker.tscn"),
	TrackEditor.Mode.Move: preload("res://ui/editor/gizmos/translate.tscn")
}

var current: Gizmo

func update_gizmo(mode: TrackEditor.Mode) -> void:
	if current != null:
		print("current gizmo exists, freeing")
		current.queue_free()
		current = null
	match mode:
		_:
			if editor.selected != null:
				print("create gizmo!")
				current = map[mode].instantiate()
				editor.selected.add_child(current)
