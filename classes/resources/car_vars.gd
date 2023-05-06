class_name CarVars
extends Resource

# index value usage
# 0     1     throttle
# 1     0     brake
# 2     0.1   steering
# 3     0,    engine force
# 4     800   engine rpm
# 5     0     wheel rpm
# 6     0     kilometers per hour
# 7     1     gear
# 8     498   position x
# ..    ...   ...
# 11    0     rotation x
# ..    ...   ...
# 14    1     skid on wheel 0
# ..    ...   ...
# 18    1     contact on wheel
# ..
# 22    -1.20 position x of wheel 0
# ..
# 33    -1.51 postiion z of wheel 4
enum {THROTTLE,BRAKE,STEERING,ENGINE_FORCE,ENGINE_RPM,WHEEL_RPM,KPH,CURRENT_GEAR} # arr[n]
const POSITION = 8 # arr2vec(pos)
const ROTATION = 11 # arr2vec(rot)
const SKID_START = 14 # arr[wheel index + skid start] = wheel skid
const CONTACT_START = 18 # arr[wi + cs] = ws
const WHEEL_POSITION_START = 22 # arr2vec(arr, (wi * 3) + ps)

static func _arr2vec(arr: PackedFloat32Array) -> Vector3:
	return Vector3(arr[0],arr[1],arr[2])

static func arr2vec(arr: PackedFloat32Array, position: int) -> Vector3:
	return _arr2vec(arr.slice(position, position + 3))

static func vec2arr(vec: Vector3) -> PackedFloat32Array:
	return PackedFloat32Array([vec[0],vec[1],vec[2]])

## 106B with ZSTD compression (144B without)
static func create(from: Car) -> PackedFloat32Array:
	var arr := PackedFloat32Array([
		snappedf(from.throttle, .1),
		snappedf(from.brake, .1),
		snappedf(from.steering, .1),
		snappedf(from.engine_force, .5),
		snappedf(from.engine_rpm, .5),
		snappedf(from.wheel_rpm, .1),
		snappedf(from.kph(), .5),
		from.current_gear,
	])
	arr.append_array(vec2arr(from.global_position))
	arr.append_array(vec2arr(from.global_rotation))
	for i in from.wheels.size():
		arr.append(snappedf(from.wheels[i].get_skidinfo(), .1))
	for i in from.wheels.size():
		arr.append(int(from.wheels[i].is_in_contact()))
	for i in from.wheels.size():
		arr.append_array(CarVars.vec2arr(from.wheels[i].position))
	return arr
