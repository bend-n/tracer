extends Node3D

@export var car: PackedScene
@export var track: TrackLoader

signal created_car(car: Car)

func _ready() -> void:
	var c: Node3D = car.instantiate()
	c.set_script(load("res://classes/human_car.gd"))
	c.show_debug = true
	add_child(c)
	c.ball.freeze = true
	c.visible = false
	c.global_position = track.start_pos + Vector3.UP * 3.5
	c.set_deferred(&"rotation", track.start_rot + Vector3.UP * PI)
	await get_tree().process_frame
	c.global_position = c.global_position - (c.ball.global_transform.basis.z * 2) # bump forward a teensy bit
	c.visible = true
	created_car.emit(c)
	for cp in track.checkpoints:
		cp.collected.connect(collect.bind(cp.id))

func collect(cp: int) -> void:
	print("collected cp %d" % cp)
	collected_checkpoints.append(cp)

var collected_checkpoints: PackedInt32Array = []
