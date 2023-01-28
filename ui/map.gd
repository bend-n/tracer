extends Line2D
class_name MiniMap

var car: Node3D
@export var track: TrackLoader
@export var player_color: Color

func _ready() -> void:
	set_process(false)
	clear_points()
	width = track.track.track_width
	if !track.track.is_loop:
		end_cap_mode = LINE_CAP_ROUND
		begin_cap_mode = LINE_CAP_ROUND
	for point_3d in track.curve.get_baked_points():
		var p := flatten(point_3d)
		add_point(p)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if !car: return
	var point := flatten(track.curve.get_closest_point(car.global_position))
	draw_circle(point, width / 2, player_color)

func flatten(vec: Vector3) -> Vector2:
	return Vector2(vec.x, vec.z)

func _on_race_created_car(_car) -> void:
	car = _car.ball
	set_process(true)

