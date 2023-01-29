extends Line2D
class_name MiniMap

var path := Path2D.new()
@export var track: TrackLoader
@export var player_color: Color
@export var finish_indicator: Texture
@export var player_indicator: Texture
@export var ghost_indicator: Texture

var followers: Array = [] # Array[[PathFollow2D, Sprite2D, Node3D]]

func _ready() -> void:
	clear_points()
	width = track.track.track_width
	if !track.track.is_loop:
		end_cap_mode = LINE_CAP_ROUND
		begin_cap_mode = LINE_CAP_ROUND

	var curve := Curve2D.new()
	curve.bake_interval = 200 # already baked
	var box := Rect2()
	for point_3d in track.curve.get_baked_points():
		var p := flatten(point_3d)
		curve.add_point(p)
		box = box.expand(p)
		add_point(p)
	path.curve = curve
	add_child(path)
	global_position = -box.position + Vector2(50, 50)
	mkfollower(track.finish, finish_indicator, Color.WHITE, false, true)

func _process(_delta: float) -> void:
	for follower in followers:
		if is_instance_valid(follower[2]):
			(follower[0] as PathFollow2D).progress = track.curve.get_closest_offset((follower[2] as Node3D).global_position)
			if !follower[0].rotates:
				(follower[1] as Sprite2D).global_rotation = -follower[2].global_rotation.y - PI/2

func vec(xy: float) -> Vector2:
	return Vector2(xy, xy)

func mkfollower(node: Node3D, tex: Texture, mod := Color.WHITE, back := false, rotates := false):
	var follower := PathFollow2D.new()
	follower.rotates = rotates
	path.add_child(follower)
	var sprite := Sprite2D.new()
	sprite.modulate = mod
	sprite.texture = tex
	follower.add_child(sprite)
	if back:
		followers.push_front([follower, sprite, node])
	else:
		followers.push_back([follower,sprite, node])

func flatten(v: Vector3) -> Vector2:
	return Vector2(v.x, v.z)

func _on_race_created_car(car: Car) -> void:
	mkfollower(car.car_mesh, player_indicator, player_color)

func _on_race_created_ghost(ghost: GhostCar) -> void:
	mkfollower(ghost, ghost_indicator, Color(1,1,1,.5), true)
