extends Node3D
class_name GhostCar

@onready var wheels: Array[Node3D] = [$bl as Node3D, $br as Node3D, $fl as Node3D, $fr as Node3D]

const trail_scene = preload("res://scenes/trail.tscn")
const inactive = {active = false};
var skids: Array[Array] = [[inactive], [inactive], [inactive], [inactive]]
var particles: Array[GPUParticles3D] = []

func _ready() -> void:
	for whl in wheels:
		particles.append(whl.get_node(^"particles"))

func update(v: Dictionary) -> void:
	wheels[2].rotation.y = v.steering * .75
	wheels[3].rotation.y = v.steering * .75
	global_rotation = v.rotation
	global_position = v.position

	for i in 4:
		particles[i].emitting = v.wheel_skidinfo[i] < (.2 if i > 2 else .99) and v.wheel_contact[i] and v.kph > 30
		if particles[i].emitting:
			@warning_ignore("narrowing_conversion")
			particles[i].amount = clampf(ceil(75 * (1 - v.wheel_skidinfo[i])) * 1 if i > 2 else 8, 0, 75)
			if !skids[i][-1].active:
				skids[i].append(trail_scene.instantiate() as Trail3D)
				get_parent().add_child(skids[i][-1])
			(skids[i][-1] as Trail3D).add(v.wheel_position[i] - Vector3(0, .661, 0))
		elif skids[i][-1].active:
			skids[i][-1].active = false

		wheels[i].global_position = v.wheel_position[i]
