extends Button

signal back

func _on_pressed() -> void:
	if %save.unsaved:
		var dialog := ConfirmationDialog.new()
		dialog.min_size = Vector2(350, 100)
		dialog.exclusive = true
		dialog.title = "Are you sure!"
		dialog.dialog_text = "You have unsaved changes!\nConsider saving first."
		dialog.cancel_button_text = "wait no"
		dialog.ok_button_text = "go ahead"
		dialog.dialog_hide_on_ok = false
		dialog.dialog_close_on_escape = false
		dialog.unresizable = true
		dialog.popup_window = true
		dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
		dialog.add_theme_stylebox_override("panel", preload("res://ui/panel_dark.stylebox"))
		add_child(dialog)
		dialog.show()
		dialog.confirmed.connect(emit_signal.bind(&"back"))
		dialog.canceled.connect(dialog.queue_free)
		dialog.confirmed.connect(dialog.queue_free)
	else:
		back.emit()



