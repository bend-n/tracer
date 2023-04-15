extends MultiButton

@onready var brush: TextureRect = $brush
@onready var outline: TextureRect = $outline
@export var cursor: Texture

func set_c(c: Color) -> void:
	if disabled:
		brush.modulate = c
	if not button_pressed:
		secondary.modulate = c
	outline.visible = button_pressed

var mat: int = 0

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is WeakLink and data.type == WeakLink.Type.Material

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	mat = data.material
	brush.modulate = data.material_color
	disabled = false

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT:
		mat = 0
		reset()

func reset() -> void:
	button_pressed = false
	disabled = true

func _toggled(on: bool) -> void:
	Input.set_custom_mouse_cursor(cursor if on else null, Input.CURSOR_ARROW)

func _on_mousecast_hit(colls: Array) -> void:
	if colls.is_empty():
		button_pressed = false
