class_name HumanCar
extends Car

func _physics_process(delta: float) -> void:
	throttle = 0
	throttle -= Input.get_axis("accel", "brake")
	throttle *= acceleration
	# Get steering input
	var steer_val := 0.0
	steer_val += Input.get_axis("ui_left", "ui_right")
	steer_val *= max_steering_range
	steer(steer_val)
	super(delta)
