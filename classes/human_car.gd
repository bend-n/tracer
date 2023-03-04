class_name HumanCar
extends Car

static func attach(to: PackedScene) -> HumanCar:
	var car := to.instantiate()
	car.set_script(load("res://classes/human_car.gd"))
	return car

func _physics_process(delta: float) -> void:
	throttle = Input.get_action_strength("accel")
	brake = Input.get_action_strength("brake") * MAX_BRAKE_FORCE
	steer(Input.get_axis("left", "right"))
	super(delta)

func shift_up():
	return Input.is_action_just_pressed("shift_up")

func shift_down():
	return Input.is_action_just_pressed("shift_down")
