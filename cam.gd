extends Camera3D
class_name CarCamera

@export var target_distance = 9.0
@export var target_height = 6.0

var follow_this: Node3D
var last_lookat: Vector3

func _ready():
	global_position = follow_this.global_position + (follow_this.global_transform.basis.z * target_distance)
	look_at(follow_this.global_position)
	last_lookat = follow_this.global_position
	far = 2000

func target() -> Vector3:
	var delta_v := global_position - follow_this.global_position
	var target_pos := global_position

	# ignore y
	delta_v.y = 0.0

	if (delta_v.length() > target_distance):
		delta_v = delta_v.normalized() * target_distance
		delta_v.y = target_height
		target_pos = follow_this.global_position + delta_v
	else:
		target_pos.y = follow_this.global_position.y + target_height
	return target_pos


func _physics_process(delta):
	global_position = global_position.lerp(target(), delta * 20.0)
	last_lookat = last_lookat.lerp(follow_this.global_position, delta * 20.0)
	look_at(last_lookat, Vector3(0.0, 1.0, 0.0))


func _init(car: Car) -> void:
	follow_this = car
