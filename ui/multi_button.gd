extends Button
class_name MultiButton

@export var secondary: Label

func update(_var = null): # cant unbind when connecting signals in code
	var color: StringName = &"font_color"
	if button_pressed:
		color = &"font_pressed_color"
	elif (is_hovered() if _var == null else _var) || has_focus():
		color = &"font_hover_color"
	secondary.label_settings.font_color = get_theme_color(color)

func _ready() -> void:
	secondary.label_settings.font_color = get_theme_color(&"font_pressed_color" if button_pressed else &"font_color")
	toggled.connect(update)
	focus_entered.connect(update)
	focus_exited.connect(update)
	mouse_entered.connect(update.bind(true))
	mouse_exited.connect(update.bind(false))
	pressed.connect(update)
	button_up.connect(update)
	button_down.connect(update)
