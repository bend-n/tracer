extends Camera3D

@export var follow_this: Node3D
@export var target_distance = 3.0
@export var target_height = 2.0

var last_lookat

func _ready():
	last_lookat = follow_this.global_transform.origin
	if follow_this is Car:
		await follow_this.ready
		follow_this = follow_this.car_mesh

func _physics_process(delta):
	var delta_v = global_transform.origin - follow_this.global_transform.origin
	var target_pos = global_transform.origin

	# ignore y
	delta_v.y = 0.0

	if (delta_v.length() > target_distance):
		delta_v = delta_v.normalized() * target_distance
		delta_v.y = target_height
		target_pos = follow_this.global_transform.origin + delta_v
	else:
		target_pos.y = follow_this.global_transform.origin.y + target_height

	global_transform.origin = global_transform.origin.lerp(target_pos, delta * 20.0)

	last_lookat = last_lookat.lerp(follow_this.global_transform.origin, delta * 20.0)

	look_at(last_lookat, Vector3(0.0, 1.0, 0.0))
