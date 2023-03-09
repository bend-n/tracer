extends Node3D
class_name GhostCar

@onready var wheels: Array[Node3D] = [$bl as Node3D, $br as Node3D, $fr as Node3D, $fl as Node3D]
@onready var body_mesh: MeshInstance3D = $body
@onready var engine: AudioStreamPlayer3D = $Engine

const trail_scene = preload("res://scenes/trail.tscn")
const inactive = {active = false};
var skids: Array[Array] = [[inactive], [inactive], [inactive], [inactive]]
var particles: Array[GPUParticles3D] = []
var v: Dictionary # [CarVars]
var current_gear := 0
var engine_rpm := 800.0

func _ready() -> void:
	for whl in wheels:
		particles.append(whl.get_node(^"particles"))

func clear_skids() -> void:
	for wheel in skids:
		if wheel:
			for skid in wheel:
				if skid is Trail3D:
					skid.queue_free()
			wheel.clear()
	skids = [[inactive], [inactive], [inactive], [inactive]]

func reset(clear_skids := true) -> void:
	engine_rpm = 800
	current_gear = 0
	for p in particles:
		p.emitting = false
	if clear_skids:
		clear_skids()

func update(car_vars: Dictionary, delta: float) -> void:
	v = car_vars
	engine_rpm = maxf(800, v.engine_rpm)
	current_gear = v.current_gear
	wheels[2].rotation.y = v.steering * .75
	wheels[3].rotation.y = v.steering * .75
	global_rotation = v.rotation
	if delta > 0:
		global_position = lerp(global_position, v.position, 10 * delta)
	else:
		global_position = v.position

	for i in 4:
		particles[i].emitting = v.wheel_skidinfo[i] < (.2 if i > 2 else .99) and v.wheel_contact[i] and v.kph > 30
		if particles[i].emitting:
			@warning_ignore("narrowing_conversion")
			particles[i].amount = clampf(ceil(75 * (1 - v.wheel_skidinfo[i])) * 1 if i > 2 else 8, 0, 75)
			if !skids[i][-1].active:
				skids[i].append(trail_scene.instantiate() as Trail3D)
				get_parent().add_child(skids[i][-1])
			(skids[i][-1] as Trail3D).add(to_global(v.wheel_position[i]) - Vector3(0, .661, 0))
		elif skids[i][-1].active:
			skids[i][-1].active = false

		wheels[i].position = v.wheel_position[i]

	body_mesh.rotation.z = lerp(body_mesh.rotation.z, clampf(((-v.steering * .001) * v.wheel_rpm) + randf_range(-0.05,0.05), -.4, .4), 5 * delta)

func kph() -> float:
	return v.kph
