extends Gizmo
class_name SelectionMarker

func _input(event: InputEvent) -> void:
	if event.is_action("rotate_cw") and event.is_pressed():
		rotated.emit(Vector3(0, PI/2, 0))
		finalize.emit()
	elif event.is_action("rotate_ccw") and event.is_pressed():
		rotated.emit(Vector3(0, -(PI/2), 0))
		finalize.emit()
