extends VehicleBody3D
class_name Car

@export var STEER_SPEED := 0.1
@export var MAX_ENGINE_FORCE := 700.0
@export var MAX_BRAKE_FORCE := 50.0

@export var gear_ratios: Array[float] # 6
@export var reverse_ratio := -2.5
@export var final_drive_ratio := 3.38
@export var max_engine_rpm := 8000.0
@export var gear_shift_time = 0.3
@export var power_curve: Curve = null

var current_gear = 0 # -1 reverse, 0 = neutral, 1 - 6 = gear 1 to 6.
const names: Array[StringName] = ["neutral", "first", "second", "third", "fourth", "fifth", "sixth", "reverse"] # -1 = last
var clutch_position: float = 1.0 # 0.0 = clutch engaged
var current_speed_mps = 0.0 # meters
@onready var last_pos = position
@export var wheel_radius: float
@onready var wheel_circumference: float = 2.0 * PI * wheel_radius
var gear_timer = 0.0

func get_speed_kph():
	return current_speed_mps * 3600.0 / 1000.0

# calculate the RPM of our engine based on the current velocity of our car
func calculate_rpm() -> float:
	# if we are in neutral, no rpm
	if current_gear == 0:
		return 0.0

	var wheel_rotation_speed: float = 60.0 * current_speed_mps / wheel_circumference
	var drive_shaft_rotation_speed: float = wheel_rotation_speed * final_drive_ratio
	if current_gear == -1:
		# we are in reverse
		return drive_shaft_rotation_speed * -reverse_ratio
	elif current_gear <= gear_ratios.size():
		return drive_shaft_rotation_speed * gear_ratios[current_gear - 1]
	return 0.0

func _process_gear_inputs(delta: float):
	if gear_timer > 0.0:
		gear_timer = max(0.0, gear_timer - delta)
		clutch_position = 0.0
	else:
		if Input.is_action_just_pressed("shift_down") and current_gear > -1:
			current_gear = current_gear - 1
			gear_timer = gear_shift_time
			clutch_position = 0.0
		elif Input.is_action_just_pressed("shift_up") and current_gear < gear_ratios.size():
			current_gear = current_gear + 1
			gear_timer = gear_shift_time
			clutch_position = 0.0
		else:
			clutch_position = 1.0

func _process(delta: float):
	_process_gear_inputs(delta)

func _physics_process(delta):
	current_speed_mps = (position - last_pos).length() / delta
	var steer_val = Input.get_axis("ui_left", "ui_right")
	var throttle_val = Input.get_action_strength("accel")
	var brake_val = Input.get_action_strength("brake")

	var power_factor = power_curve.sample_baked(clamp(calculate_rpm() / max_engine_rpm, 0.0, 1.0))

	if current_gear == -1:
		engine_force = clutch_position * throttle_val * power_factor * reverse_ratio * final_drive_ratio * MAX_ENGINE_FORCE
	elif current_gear > 0 and current_gear <= gear_ratios.size():
		engine_force = clutch_position * throttle_val * power_factor * gear_ratios[current_gear - 1] * final_drive_ratio * MAX_ENGINE_FORCE
	else:
		engine_force = 0.0

	brake = brake_val * MAX_BRAKE_FORCE
	steering = clamp(lerpf(steering + -(steer_val * STEER_SPEED), 0, STEER_SPEED), -.8, .8)
	print("%0.2f" % steering)
	if is_zero_approx(steering) or (steering < .05 && steering > -.05):
		steering = 0

	# remember where we are
	last_pos = position
