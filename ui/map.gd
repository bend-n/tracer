extends Line2D

@export var track: TrackLoader

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	clear_points()
	width = track.track.track_width
	for point_3d in track.curve.get_baked_points():
		var p := Vector2(point_3d.x, point_3d.z) / 2
		add_point(p)
