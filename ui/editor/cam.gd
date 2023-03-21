extends Camera3D

var freelook := false;
var panning := false;
var mp_before_freelook := Vector2.ZERO;
const MOUSE_SENSITIVTY = 0.02;
const PAN_SENSITIVITY = 0.005;
const SCROLL_SENS = 2;
const CAMERA_MAX_ROTATION_ANGLE = deg_to_rad(70);

func _process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			mp_before_freelook = get_viewport().get_mouse_position()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
			freelook = true;
	elif Input.is_action_pressed("ui_pan"):
		var vel := Input.get_last_mouse_velocity() * PAN_SENSITIVITY
		global_position += Vector3(vel.x, -vel.y, 0)
	else:
		if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
			freelook = false;
			get_viewport().warp_mouse(mp_before_freelook)

func _input(event: InputEvent):
	if freelook and event is InputEventMouseMotion:
		rotation.x = clamp(rotation.x + (-event.relative.y * MOUSE_SENSITIVTY), -CAMERA_MAX_ROTATION_ANGLE, CAMERA_MAX_ROTATION_ANGLE);
		rotation.y += -event.relative.x * MOUSE_SENSITIVTY;
	elif event is InputEventMouseButton:
		match event.button_index:
			# camera zoom
			MOUSE_BUTTON_WHEEL_UP: global_position -= global_transform.basis.z * SCROLL_SENS
			MOUSE_BUTTON_WHEEL_DOWN: global_position += global_transform.basis.z * SCROLL_SENS
