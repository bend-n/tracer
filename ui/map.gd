extends Line2D

@export var track: TrackLoader
@export var car: Node3D
@export var player_color: Color

func _ready() -> void:
	clear_points()
	width = track.track.track_width
	# am on the fence about outlining
	# var outline := Line2D.new()
	# outline.width = width + 10
	# outline.default_color = Color.BLACK
	# outline.show_behind_parent = true
	# outline.antialiased = true
	# outline.joint_mode = LINE_JOINT_ROUND
	# add_child(outline)
	for point_3d in track.curve.get_baked_points():
		var p := flatten(point_3d)
		add_point(p)
		# outline.add_point(p)


func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var point := flatten(track.curve.get_closest_point(car.ball.global_position))
	draw_circle(point, width / 2, player_color)

func flatten(vec: Vector3) -> Vector2:
	return Vector2(vec.x, vec.z)
