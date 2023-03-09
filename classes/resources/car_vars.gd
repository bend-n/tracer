class_name CarVars
extends Resource

var throttle: float
var brake: float
var steering: float
var engine_force: float
var engine_rpm: float
var wheel_rpm: float
var wheel_skidinfo: Array
var wheel_contact: Array
var wheel_position: Array
var current_gear: int
var position: Vector3
var rotation: Vector3
var kph: float

func _init(from: Car) -> void:
	throttle = from.throttle
	brake = from.brake
	steering = from.steering
	engine_force = from.engine_force
	engine_rpm = from.engine_rpm
	position = from.global_position
	rotation = from.global_rotation
	wheel_rpm = from.wheel_rpm
	current_gear = from.current_gear
	for i in from.wheels.size():
		var wheel := from.wheels[i]
		wheel_skidinfo.append(wheel.get_skidinfo())
		wheel_contact.append(wheel.is_in_contact())
		wheel_position.append(wheel.position)
	kph = from.kph()

func to_dict(): # RIP memory
	return {
		throttle = throttle, brake = brake, steering = steering,
		engine_force = engine_force, engine_rpm = engine_rpm,
		position = position, rotation = rotation, kph = kph,
		wheel_skidinfo = wheel_skidinfo, wheel_contact = wheel_contact,
		wheel_position = wheel_position, current_gear = current_gear,
		wheel_rpm = wheel_rpm
	}
