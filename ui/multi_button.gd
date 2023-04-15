extends Button
class_name MultiButton

@export var secondary: Control

func update(_var = null): # cant unbind when connecting signals in code
	var color: StringName = &"font_color"
	if disabled:
		color = &"font_disabled_color"
	elif button_pressed:
		color = &"font_pressed_color"
	elif (is_hovered() if _var == null else _var) || has_focus():
		color = &"font_hover_color"
	set_c(get_theme_color(color))

func set_c(c: Color) -> void:
	if secondary is Label:
		secondary.label_settings.font_color = c
	elif secondary is TextureRect:
		secondary.modulate = c

func _ready() -> void:
	update()
	toggled.connect(update)
	focus_entered.connect(update)
	focus_exited.connect(update)
	mouse_entered.connect(update.bind(true))
	mouse_exited.connect(update.bind(false))
	pressed.connect(update)
	button_up.connect(update)
	button_down.connect(update)
