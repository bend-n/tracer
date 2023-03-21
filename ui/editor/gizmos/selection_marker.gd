extends Gizmo
class_name SelectionMarker

func mktween():
	return get_tree().create_tween().bind_node(object).set_trans(Tween.TRANS_BACK)

func _input(event: InputEvent) -> void:
	if event.is_action("rotate_cw") and event.is_pressed():
		mktween().tween_property(
			object,
			^"global_rotation",
			object.global_rotation + Vector3(0, PI/2, 0),
			.5
		)
	elif event.is_action("rotate_ccw") and event.is_pressed():
		mktween().tween_property(
			object,
			^"global_rotation",
			object.global_rotation + Vector3(0, -(PI/2), 0),
			.2
		)
