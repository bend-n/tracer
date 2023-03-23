extends Line2D
class_name MiniMap

var path := Path2D.new()
var track: TrackLoader

@export var player_color: Color
@export var finish_indicator: Texture
@export var player_indicator: Texture
@export var ghost_indicator: Texture

var followers: Array = [] # Array[[PathFollow2D, Sprite2D, Node3D]]

func _ready() -> void:
	clear_points()
	width = 10
#	if !track.track.is_loop:
#		end_cap_mode = LINE_CAP_ROUND
#		begin_cap_mode = LINE_CAP_ROUND

	var curve := Curve2D.new()
	curve.bake_interval = 200 # already baked
	var box := Rect2()
	for block in track.track.blocks:
		var p := flatten(block.transform.origin)
		curve.add_point(p)
		box = box.expand(p)
		add_point(p)
	path.curve = curve
	add_child(path)
	position = -box.position
	scale = vec((add((get_parent() as Container).get_rect().size) / add(box.size))/2)
	mkfollower(track.finish, finish_indicator, Color.WHITE, false, true)

func _process(_delta: float) -> void:
	return
#	for follower in followers:
#		if is_instance_valid(follower[2]):
#			(follower[0] as PathFollow2D).progress = track.curve.get_closest_offset((follower[2] as Node3D).global_position)
#			if !follower[0].rotates:
#				(follower[1] as Sprite2D).global_rotation = -follower[2].global_rotation.y - PI/2

func mkfollower(node: Node3D, tex: Texture, mod := Color.WHITE, back := false, rotates := false):
	return
#	if !is_instance_valid(node):
#		push_warning("invalid follower")
#		return
#	var follower := PathFollow2D.new()
#	follower.rotates = rotates
#	path.add_child(follower)
#	var sprite := Sprite2D.new()
#	sprite.modulate = mod
#	sprite.texture = tex
#	follower.add_child(sprite)
#	if back:
#		followers.push_front([follower, sprite, node])
#	else:
#		followers.push_back([follower,sprite, node])

func vec(f: float) -> Vector2:
	return Vector2(f, f)

func add(v: Vector2) -> float:
	return v.x + v.y

func flatten(v: Vector3) -> Vector2:
	return Vector2(v.x, v.z)

func assigned(car, ghost: GhostCar, _timer, _track: TrackLoader) -> void:
	mkfollower(ghost, ghost_indicator, Color(1,1,1,.5), true)
	if car != ghost:
		mkfollower(car, player_indicator, player_color)
	track = _track
