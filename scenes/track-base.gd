@tool
extends Path3D

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
@onready var support := $Support as CSGPolygon3D
@onready var rail_l := $"Rail-L" as CSGPolygon3D
@onready var rail_r := $"Rail-R" as CSGPolygon3D
@onready var collision := $CollisionShape as CSGPolygon3D

var is_dirty = true

func vec(x := 0.0, y := 0.0) -> Vector2:
	return Vector2(x, y)


func _update():
	if !is_dirty or !track or !track.track:
		# curve = null
		return
	curve = track.track
	curve.set_point_tilt(0, PI/2)
	curve.set_point_tilt(curve.get_point_count() - 1, 0.0)

	# update our track
	var thw = track.track_width * 0.5 # track half width
	road.polygon = PackedVector2Array([vec(-thw), vec(-thw, -0.1), vec(thw, -0.1), vec(thw)])
	support.polygon = PackedVector2Array([
		vec(-thw - 2.0, -0.17),
		vec( thw + 2.0, -0.17),
		vec( track.lower_support_width + 0.1, -track.support_height),
		vec(-track.lower_support_width, -track.support_height)
	])

	# update our rails

	var rp := thw + track.rail_distance # rail position
	rail_l.polygon = PackedVector2Array([
		vec(rp, 0.5),
		vec(rp - 0.05, 0.47),
		vec(rp - 0.05, 0.43),
		vec(rp, 0.4),
		vec(rp, 0.55),
		vec(rp - 0.05, 0.32),
		vec(rp - 0.05, 0.28),
		vec(rp, 0.25),
		vec(rp  + 0.05, 0.25),
		vec(rp + 0.05, 0.5)
	])
	rail_r.polygon = PackedVector2Array([
		vec(-rp, 0.5),
		vec(-rp + 0.05, 0.47),
		vec(-rp + 0.05, 0.43),
		vec(-rp, 0.4),
		vec(-rp, 0.55),
		vec(-rp + 0.05, 0.32),
		vec(-rp + 0.05, 0.28),
		vec(-rp, 0.25),
		vec(-rp - 0.05, 0.25),
		vec(-rp - 0.05, .5)
	])

	# update our collision

	var c = collision.polygon
	c.set(0, Vector2(-rp, 0.0))
	c.set(1, Vector2( rp, 0.0))
	c.set(2, Vector2( rp, 5.0))
	c.set(3, Vector2( rp + 3.0, 5.0))
	c.set(4, Vector2( rp + 3.0, -1.0))
	c.set(5, Vector2(-rp - 3.0, -1.0))
	c.set(6, Vector2(-rp - 3.0, 5.0))
	c.set(7, Vector2(-rp, 5.0))
	collision.polygon = c

	is_dirty = false

func _ready():
	call_deferred("_update")


func _on_curve_changed() -> void:
	is_dirty = true
	call_deferred("_update")
