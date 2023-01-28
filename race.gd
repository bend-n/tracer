extends Node3D

@export var car: PackedScene
@export var track: TrackLoader
@export var splits: Control
@export var timer: Control

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
	for i in len(track.checkpoints):
		track.checkpoints[i].collected.connect(collect.bind(i))

	track.finish.collected.connect(
		func passed_finish() -> void:
			if track.checkpoints.size() == len(collected_checkpoints):
				collect(-1)
	)

func collect(cp: int) -> void:
	splits.update(timer.elapsed_time, 10)
	collected_checkpoints.append(cp)

var collected_checkpoints: PackedInt32Array = []
