extends Camera3D

var freelook := false;

const CONTROL_SPEED = 10;
const MOVE_SPEED = 50;
const SHIFT_SPEED = 100;

const MOUSE_SENSITIVTY = 0.04;

const CAMERA_MAX_ROTATION_ANGLE = deg_to_rad(70);

func _process(delta):
	if (Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)):
		if (Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
		freelook = true;
	else:
		if (Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
		freelook = false;

	process_movement(delta);

func process_movement(delta):
	var movement_vector := Vector3(Input.get_axis("ui_left", "ui_right"), 0, Input.get_axis("ui_down", "ui_up"))
	var movement_speed := MOVE_SPEED;

	if (Input.is_key_pressed(KEY_SHIFT)):
		movement_speed = SHIFT_SPEED;
	elif (Input.is_key_pressed(KEY_CTRL)):
		movement_speed = CONTROL_SPEED;

	global_position += -global_transform.basis.z * movement_vector.z * movement_speed * delta
	global_position += global_transform.basis.x * movement_vector.x * movement_speed * delta


func _input(event: InputEvent):
	if freelook and event is InputEventMouseMotion:
		rotation.x = clamp(rotation.x + (-event.relative.y * MOUSE_SENSITIVTY), -CAMERA_MAX_ROTATION_ANGLE, CAMERA_MAX_ROTATION_ANGLE);
		rotation.y += -event.relative.x * MOUSE_SENSITIVTY;
