extends Camera3D

var follow_this: Node3D
@export var target_distance = 3.0
@export var target_height = 2.0

var last_lookat

func _ready():
	set_physics_process(false)


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


func _on_race_created_car(car: Car) -> void:
	follow_this = car.car_mesh
	global_position = follow_this.global_position + (follow_this.global_transform.basis.z * target_distance)
	look_at(follow_this.global_position)
	last_lookat = follow_this.global_position
	set_physics_process(true)
