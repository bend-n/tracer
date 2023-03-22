extends Node3D
class_name TrackLoader

@export_group("Track")
@export var track: TrackResource = null:
	set(new_track):
		if track != new_track:
			track = new_track
			is_dirty = true
			call_deferred("_update")

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
	sun.rotation_degrees.x = track.sun_x
	sun.rotation_degrees.y = track.sun_y
	ground.global_position = track.offset
	for block in track.blocks:
		var node: Node3D = block.base_scene.instantiate()
		add_child(node)
		(node.mesh as MeshInstance3D).set_surface_override_material(0, block.material)
		(node as Node3D).global_transform = block.transform
		block.set_live(node) # this discards transform and material data
	print("created track!")

func _ready():
	_update()

