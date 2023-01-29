extends Line2D
class_name MiniMap

var car: Node3D
@export var track: TrackLoader
@export var player_color: Color
@export var finish_indicator: Texture

func _ready() -> void:
	set_process(false)
	clear_points()
	width = track.track.track_width
	if !track.track.is_loop:
		end_cap_mode = LINE_CAP_ROUND
		begin_cap_mode = LINE_CAP_ROUND

	var box := Rect2()
	for point_3d in track.curve.get_baked_points():
		var p := flatten(point_3d)
		box = box.expand(p)
		add_point(p)
	global_position = -box.position + Vector2(50, 50)


func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if !car: return

	draw_player()
	draw_finish()

func draw_player() -> void:
	var point := flatten(track.curve.get_closest_point(car.global_position))
	draw_circle(point, (width - 2) / 2, player_color)

func draw_finish() -> void:
	draw_texture(finish_indicator, flatten(track.curve.get_closest_point(track.finish.global_position)) + Vector2.UP * 14)

func vec(xy: float) -> Vector2:
	return Vector2(xy, xy)

func flatten(v: Vector3) -> Vector2:
	return Vector2(v.x, v.z)

func _on_race_created_car(_car) -> void:
	car = _car.ball
	set_process(true)

