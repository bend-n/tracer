extends Camera3D

var freelook := false;
var panning := false;
var mp_before_freelook := Vector2.ZERO;
const MOUSE_SENSITIVTY = 0.02;
const PAN_SENSITIVITY = 0.5;
const SCROLL_SENS = 2;
const CAMERA_MAX_ROTATION_ANGLE = deg_to_rad(70);

var m_vel := Vector2.ZERO
@onready var last_m_pos := get_viewport().get_mouse_position()

func _ready() -> void:
	fov = Globals.cfg.get_value(SettingsSaver.GRAPHIC, "camera_fov")

func _process(_delta):
	m_vel = get_viewport().get_mouse_position() - last_m_pos
	last_m_pos = get_viewport().get_mouse_position()
	if Input.is_action_pressed(&"freelook"):
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			mp_before_freelook = get_viewport().get_mouse_position()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
			freelook = true;
	elif Input.is_action_pressed("ui_pan"):
		var vel := m_vel * PAN_SENSITIVITY
		position -= (transform.basis.x * vel.x)
		position += (transform.basis.y * vel.y)
		panning = true
	else:
		if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
			freelook = false;
			get_viewport().warp_mouse(mp_before_freelook)
		panning = false

func _input(event: InputEvent):
	if freelook and event is InputEventMouseMotion:
		rotation.x = clamp(rotation.x + (-event.relative.y * MOUSE_SENSITIVTY), -CAMERA_MAX_ROTATION_ANGLE, CAMERA_MAX_ROTATION_ANGLE);
		rotation.y += -event.relative.x * MOUSE_SENSITIVTY;
	elif event.is_action(&"zoom_in"):
		global_position -= global_transform.basis.z * SCROLL_SENS
	elif event.is_action(&"zoom_out"):
		global_position += global_transform.basis.z * SCROLL_SENS
	elif event is InputEventMouseMotion and panning:
		var v := get_viewport()
		var mp := v.get_mouse_position()
		if not Rect2(Vector2(), v.size).grow(-15).has_point(mp):
			v.warp_mouse(mp.posmodv(v.size))
			last_m_pos = mp.posmodv(v.size)
