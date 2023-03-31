extends Resource
class_name TrackResource
@export_group("Sun position")
## Sun x rotation
@export_range(-360, 360) var sun_x := -90
## Sun y rotation ( its a game, the sun rotates around us )
@export_range(-360, 360) var sun_y := 0
@export_group("", "")
## The height of the overview cam
@export var overview_height := 300.0
## The name of this track
@export var name: String = ""
## Offset the entire track
@export var offset := Vector3.UP
@export_group("Race")
## Num laps, 1 = go to finish and done
@export var laps := 1

## should look something like:
## [codeblock]
## [
##   TrackObject {
##      scene: "res://assets/blocks/platform.tscn",
##      transform: Transform3D(0, 0, 1, 0),
##      material: "platform",
##      ...more fields i come up with
##    }
##  ]
## [/codeblock]
var blocks: Array[TrackObject]

func _init(p_blocks: Array[TrackObject]) -> void:
	blocks = p_blocks

static func from_d(d: Dictionary) -> TrackResource:
	var blocs: Array[TrackObject] = []
	for block in d.blocks:
		blocs.append(TrackObject.from_d(block))
	var obj := TrackResource.new(blocs)
	obj.sun_x = d.sun_x
	obj.sun_y = d.sun_y
	obj.overview_height = d.overview_height
	obj.name = d.name
	obj.offset = d.offset
	obj.laps = d.laps
	return obj

## Creates a [TrackResource] from a file
static func _load(path: String) -> TrackResource:
	var res := GhostData._load_file(path)
	if res.is_empty():
		return null
	return TrackResource.from_d(res)


func save(path: String) -> void:
	var b: Array[Dictionary] = [] # i know map() exists, but it didnt work
	for i in blocks:
		b.append(i.exprt())
	var d := {
		sun_x = sun_x,
		sun_y = sun_y,
		overview_height = overview_height,
		name = name,
		offset = offset,
		laps = laps,
		blocks = b
	}
	GhostData._save_file(path, d)

func get_aabb() -> AABB:
	var box := AABB()
	for block in blocks:
		if block.live_node is VisualInstance3D:
			box = box.merge(block.live_node.get_aabb())
	return box
