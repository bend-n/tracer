extends Camera3D
class_name IntroCam

signal finished

var track: TrackResource
var main_cam: Camera3D

func _init(_track: TrackResource, _main_cam: Camera3D):
	far = 4000
	near = .2
	track = _track
	main_cam = _main_cam

func _ready() -> void:
	make_current()
	var box := AABB()
	for i in track.track.point_count:
		box = box.expand(track.track.get_point_position(i))
	var box_center := box.get_center()
	var top_center := Vector3(box_center.x, track.overview_height, box_center.z)
	global_position = top_center
	global_rotation_degrees.x = -90
	await get_tree().create_timer(2).timeout
	var tween := get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, ^"global_position", main_cam.global_position, 2)
	tween.tween_property(self, ^"global_rotation", main_cam.global_rotation, 1)
	await tween.finished
	finished.emit()
	main_cam.make_current()
