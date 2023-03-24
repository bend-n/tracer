extends SubViewport

@onready var editor: TrackEditor = owner

const map = {
	TrackEditor.Mode.Select: preload("res://ui/editor/gizmos/selection_marker.tscn"),
	TrackEditor.Mode.Move: preload("res://ui/editor/gizmos/translate.tscn")
}

var current: Gizmo
var gizmo_mover: RemoteTransform3D
@export var delete: InputEvent
signal deleted

func update_gizmo(mode: TrackEditor.Mode) -> void:
	if current != null:
		print("current gizmo exists, freeing")
		current.queue_free()
		current = null
	if gizmo_mover != null:
		gizmo_mover.queue_free()
		gizmo_mover = null
	match mode:
		_:
			if editor.selected != null:
				print("create gizmo!")
				current = map[mode].instantiate()
				current.snapping = editor.snapping
				current.path = editor.selected.get_path()
				gizmo_mover = RemoteTransform3D.new()
				gizmo_mover.update_rotation = false
				gizmo_mover.update_scale = false
				gizmo_mover.update_position = true
				add_child(current)
				gizmo_mover.remote_path = current.get_path()
				editor.selected.add_child(gizmo_mover)

func _on_snapping_toggled(button_pressed: bool) -> void:
	if current != null:
		current.snapping = button_pressed

func _input(event: InputEvent) -> void:
	if event.is_match(delete) and current != null:
		current.queue_free()
		current = null
		deleted.emit()
