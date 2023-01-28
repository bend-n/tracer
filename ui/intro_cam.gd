extends Camera3D

@export var main_cam: Camera3D
@export var track: TrackLoader
@export var count_player: AnimationPlayer

var car: Car

func _ready() -> void:
	var box := AABB()
	for point in track.track.track.get_baked_points():
		box = box.expand(point)
	box = box.grow(200)
	var box_center := box.get_center()
	var top_center := Vector3(box_center.x, -box.position.y, box_center.z)
	global_position = top_center
	await get_tree().create_timer(2).timeout
	var tween := get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, ^"global_position", main_cam.global_position, 2)
	tween.tween_property(self, ^"global_rotation", main_cam.global_rotation, 1)
	await tween.finished
	count_player.play(&"count_in", -1, 2)
	await count_player.animation_finished
	car.ball.freeze = false

func _on_race_created_car(_car: Car) -> void:
	car = _car
