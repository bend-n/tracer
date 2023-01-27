extends Car
class_name AICar

const num_rays := 32
const look_ahead := 40.0
const hidden_nodes := 17
const output_nodes := 3

var rays: Array[RayCast3D]
var nn: NeuralNetwork


func _ready():
	super()
	randomize()
	acceleration *= randf_range(0.7, 1)
	add_rays()
	# +1 for speed
	nn = NeuralNetwork.new(num_rays + 1, hidden_nodes, output_nodes)


func add_rays():
	var n: float = 2 * PI / num_rays
	var ray_holder := $CarMesh/ContextRays
	for i in num_rays:
		var r := RayCast3D.new()
		ray_holder.add_child(r)
		r.target_position = Vector3.FORWARD * look_ahead
		r.rotation.y = (-n * i)
		rays.append(r)


func get_distances() -> Array[float]:
	var distances: Array[float] = []
	for i in num_rays:
		var distance: float = 1.0
		if rays[i].is_colliding():
			var raycast_length: float = rays[i].target_position.y
			var collision: Vector3 = rays[i].get_collision_point()
			distance = rays[i].global_transform.origin.distance_to(collision) / raycast_length
		distances.append(distance)
	return distances

func _physics_process(delta: float) -> void:
	var distances := get_distances()
	distances.append(ball.linear_velocity.length_squared())
	var outputs := nn.predict(distances) # [steer_l, throt, steer_r]
	print(outputs)
	var steer_target = (outputs[0] - outputs[2]) * max_steering_range
	throttle = acceleration * outputs[1]
	steer(steer_target)
	super(delta)
