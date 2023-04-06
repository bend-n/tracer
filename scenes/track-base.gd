extends Node3D
class_name TrackLoader

@export var track: TrackResource = null
@onready var sun := $Sun as DirectionalLight3D
@onready var ground := $Ground as StaticBody3D

var checkpoints: Array[CheckPoint]
var finish: Finish
var start_transf: Transform3D
var editor := false

func update():
	sun.rotation_degrees.x = track.sun_x
	sun.rotation_degrees.y = track.sun_y
	ground.global_position = track.offset
	for block in track.blocks:
		var node: Block = block.create(editor)
		add_child(node)
		if editor:
			block.set_live(node)
		if not editor:
			if node is CheckPoint:
				checkpoints.append(node)
			elif node is Finish:
				finish = node
			elif node is Start:
				start_transf = block.transform

func _ready():
	update()
