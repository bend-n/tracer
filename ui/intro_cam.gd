extends Camera3D
class_name IntroCam

signal finished

var track: TrackResource
var main_cam: Camera3D

# if main_cam null, dont animate
func _init(_track: TrackResource, _main_cam: Camera3D):
	far = 4000
	near = .2
	track = _track
	main_cam = _main_cam
	attributes = CameraAttributesPractical.new()

static func get_origin(t: TrackResource) -> Transform3D:
	var box := t.get_aabb()
	var box_center := box.get_center()
	var top_center := Vector3(box_center.x, t.overview_height, box_center.z)
	return Transform3D(Basis.from_euler(Vector3(-PI/2, 0, 0)), top_center)

func _ready() -> void:
	make_current()
	transform = IntroCam.get_origin(track)
	if is_instance_valid(main_cam):
		await get_tree().create_timer(2).timeout
		var tween := get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(self, ^"global_position", main_cam.global_position, 2)
		tween.tween_property(self, ^"global_rotation", main_cam.global_rotation, 1)
		await tween.finished
		finished.emit()
		main_cam.make_current()
