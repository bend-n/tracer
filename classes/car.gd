extends VehicleBody3D
class_name Car

@export var STEER_SPEED := 1.0
@export var steer_curve: Curve = preload("res://assets/cars/kenney_sedan/steer_curve.tres")

var steer_target := 0.0

const trail_scene = preload("res://scenes/trail.tscn")
@export var MAX_ENGINE_FORCE := 4000.0
@export var MAX_BRAKE_FORCE := 35.0
@export var reverse_ratio := -2.5
@export var final_drive_ratio := 3.38
@export var max_engine_rpm := 8000.0
@export var gear_shift_time = 0.3
@export var power_curve: Curve = preload("res://assets/cars/kenney_sedan/power_curve.tres")
@onready var body_mesh := $body as MeshInstance3D
@onready var checkpoint_sound := $checkpoint as AudioStreamPlayer

@onready var wheels: Array[VehicleWheel3D] = [$bl as VehicleWheel3D, $br as VehicleWheel3D, $fl as VehicleWheel3D, $fr as VehicleWheel3D]
var particles: Array[GPUParticles3D] = []

signal shifted

var gear_ratios: Array[float] = [ 5 ]
var current_gear := 0 # -1 reverse, 0 = neutral, 1 - 6 = gear 1 to 6.
var clutch_position := 1 # 0.0 = clutch engaged
var gear_timer := 0.0
var throttle := 0.0
var skids: Array[Array]


func ratio() -> float:
	match current_gear:
		0: return 0
		-1: return reverse_ratio
		_: return gear_ratios[current_gear - 1]

func downforce(force: float):
	apply_force(basis * Vector3(0,-force,0), Vector3(0,1.4,2.5))

func is_on_ground() -> bool:
	return wheels.all(func(whl: VehicleWheel3D): return whl.is_in_contact() != null)

func is_not_on_ground() -> bool:
	return wheels.any(func(whl: VehicleWheel3D): return !whl.is_in_contact())

func reset() -> void:
	brake = 15
	set_physics_process(false)

func _ready() -> void:
	for whl in wheels:
		particles.append(whl.get_node(^"particles"))
		skids.append([{active = false}]) # performance and complexity hack
	randomize()

func kph():
	return (3 * PI * wheels[0].wheel_radius * rpm()) / 25;

# calculate the RPM of our engine based on the average of the wheels
func rpm() -> float:
	var sum := 0.0
	for wheel in wheels:
		sum += abs(wheel.get_rpm())
	return sum / 4

func steer(to: float) -> void:
	if (abs(to) < 0.05):
		to = 0.0
	else:
		to = -steer_curve.sample_baked(-to) if to < 0.0 else steer_curve.sample_baked(to)

	steer_target = lerpf(steer_target, to, 10 * get_physics_process_delta_time())

## virtual
func shift_down() -> bool:
	return false

## virtual
func shift_up() -> bool:
	return false

func _process_gear_inputs(delta: float):
	if gear_timer > 0.0:
		gear_timer = max(0.0, gear_timer - delta)
		clutch_position = 0
	else:
		if shift_down() and current_gear > -1:
			current_gear = current_gear - 1
			gear_timer = gear_shift_time
			clutch_position = 0
			shifted.emit()
		elif shift_up() and current_gear < gear_ratios.size():
			current_gear = current_gear + 1
			gear_timer = gear_shift_time
			clutch_position = 0
			shifted.emit()
		else:
			clutch_position = 1

func _process(delta: float):
	_process_gear_inputs(delta)

func limit(delta: float) -> void:
	linear_damp = max((.5 * delta) * (kph() - 400), 0) if kph() > 400 else 0.0
	angular_damp = max(5 * (angular_velocity.length_squared() - 45), 0) if angular_velocity.length_squared() > 45 else 0.0

func _physics_process(delta: float):
	downforce(5)
	var power_factor := power_curve.sample_baked(clampf(rpm() / max_engine_rpm, 0.0, 1.0))
	if current_gear == -1:
		engine_force = throttle * power_factor * reverse_ratio * final_drive_ratio * MAX_ENGINE_FORCE * clutch_position
	elif current_gear > 0 and current_gear <= gear_ratios.size():
		engine_force = throttle * power_factor * gear_ratios[current_gear - 1] * final_drive_ratio * MAX_ENGINE_FORCE * clutch_position
	else:
		engine_force = 0.0

	steering = -clampf(steer_target, -.7, .7)
	body_mesh.rotation.z = lerp(body_mesh.rotation.z, clampf(((-steering * .2) * linear_velocity.length_squared() / 685.0) + randf_range(-0.05,0.05), -.4, .4), 10 * delta)
	limit(delta)

	for i in 4:
		particles[i].emitting = wheels[i].get_skidinfo() < (.2 if i > 2 else .8) and wheels[i].is_in_contact() and kph() > 30
		if particles[i].emitting:
			particles[i].amount = ceil(100 * (1 - wheels[i].get_skidinfo()))
			var init := false
			if !skids[i][-1].active:
				init = true
				skids[i].append(trail_scene.instantiate() as Trail3D)
				get_parent().add_child(skids[i][-1])
				(skids[i][-1] as Trail3D).add(wheels[i].global_position - Vector3(0, .661, 0))
			if not init and Engine.get_physics_frames() % 4 == 0:
				(skids[i][-1] as Trail3D).add(wheels[i].global_position - Vector3(0, .661, 0))
		elif skids[i][-1].active:
				skids[i][-1].active = false

func start() -> void:
	brake = 0
	set_physics_process(true)
