extends SubViewport

@onready var editor: TrackEditor = owner

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
				current.snapping = editor.snapping
				current.path = editor.selected.get_path()
				add_child(current)

func _on_snapping_toggled(button_pressed: bool) -> void:
	if current != null:
		current.snapping = button_pressed
