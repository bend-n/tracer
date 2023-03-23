extends TrackButton
class_name TrackEditableButton

signal edit
signal delete

func _on_delete_pressed() -> void:
	var dialog := ConfirmationDialog.new()
	dialog.min_size = Vector2(250, 100)
	dialog.exclusive = true
	dialog.title = "Are you sure!"
	dialog.dialog_text = "Delete track!"
	dialog.cancel_button_text = "no way"
	dialog.ok_button_text = "yea sure"
	dialog.dialog_hide_on_ok = false
	dialog.dialog_close_on_escape = false
	dialog.unresizable = true
	dialog.popup_window = true
	dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	dialog.add_theme_stylebox_override("panel", preload("res://ui/panel_dark.stylebox"))
	add_child(dialog)
	dialog.show()
	dialog.confirmed.connect(emit_signal.bind(&"delete"))
	dialog.canceled.connect(dialog.queue_free)
	dialog.confirmed.connect(dialog.queue_free)

