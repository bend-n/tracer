@tool
extends Path3D
class_name TrackLoader

@export_group("Track")
@export var track: TrackResource = null:
	set(new_track):
		if track != new_track:
			track = new_track
			is_dirty = true
			call_deferred("_update")
@export var force_update: bool = false:
	set(update):
		if update == true && update != force_update:
			force_update = false
			is_dirty = true
			call_deferred("_update")

@onready var road := $Road as CSGPolygon3D
@onready var rail_l := $WallL as CSGPolygon3D
@onready var rail_r := $WallR as CSGPolygon3D
@onready var collision := $CollisionShape as CSGPolygon3D
@onready var sun := $Sun as DirectionalLight3D
@onready var ground := $Ground as StaticBody3D

var checkpoints: Array[CheckPoint]
var finish: Finish
var start_rot: Vector3
var start_pos: Vector3
var is_dirty := true

func vec(x := 0.0, y := 0.0) -> Vector2:
	return Vector2(x, y)

func _update():
	if !is_dirty or !track or !track.track:
		# curve = null # editor freezes with this, idk why
		return
	curve = track.track
	curve.set_point_tilt(0, PI/2)
	curve.set_point_tilt(curve.get_point_count() - 1, 0.0)

	sun.rotation_degrees.x = (track.sun_x)
	sun.rotation_degrees.y = (track.sun_y)


	# update our track
	var thw := track.track_width * 0.5 # track half width
	road.polygon = PackedVector2Array([vec(-thw), vec(-thw), vec(thw), vec(thw)])

	# update our rails
	var outer := thw + track.barrier_width
	rail_l.polygon = PackedVector2Array([
		vec(outer, 2),
		vec(thw, 2), # widen
		vec(thw), # widen
		vec(outer)
	])
	rail_l.visible = track.left_barrier
	rail_r.polygon = PackedVector2Array([
		vec(-outer, 2),
		vec(-thw, 2), # widen
		vec(-thw), # widen
		vec(-outer)
	])
	rail_r.visible = track.right_barrier

	# update our collision
	collision.polygon = PackedVector2Array([
		vec(-thw), # widen
		vec(thw), # widen
		vec(thw, 5.0), # widen
		vec(outer, 5.0),
		vec(outer, -1.0),
		vec(-outer, -1.0),
		vec(-outer, 5.0),
		vec(-thw, 5.0), # widen
	])
	# objects
	for child in get_children():
		if child is PathFollow3D:
			child.queue_free()

	for i in len(track.checkpoints):
		var c: CheckPoint = make_follower(track.checkpoint_scene, track.checkpoints[i], track.checkpoint_scale, track.checkpoint_needs_collision)
		if not Engine.is_editor_hint(): # godot tools are wierd
			checkpoints.append(c)

	finish = make_follower(track.finish_scene, track.finish_location, track.finish_scale, track.finish_needs_collision)
	if track.laps == 1:
		var s: Start = make_follower(track.start_scene, track.start_location, track.start_scale, track.start_needs_collision)
		start_pos = s.global_position
		start_rot = s.global_rotation
	else:
		start_pos = finish.global_position
		start_rot = finish.global_rotation

	# loopage
	rail_l.path_joined = track.is_loop
	rail_r.path_joined = track.is_loop
	collision.path_joined = track.is_loop
	road.path_joined = track.is_loop

	# offset
	ground.global_position = track.offset

	is_dirty = false

func _ready():
	_update()

func _on_curve_changed() -> void:
	is_dirty = true
	call_deferred("_update")

func make_follower(scene: PackedScene, ratio: float, scl: Vector3, collide: bool) -> PathFollow3D:
	var follower: PathFollow3D = scene.instantiate()
	follower.needs_collision = collide
	add_child(follower)
	follower.scale = scl
	follower.progress_ratio = ratio # ratio set must be after add_child()
	return follower
