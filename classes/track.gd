extends Resource
class_name TrackResource
@export_group("Road")
## Width of road
@export var track_width := 40.0
## Support base width
@export var lower_support_width := 25.0
## Height of supports
@export var support_height := 8.0
## Track curve
@export var track: Curve3D = null
@export_subgroup("Barriers")
## Left barrier? (does not change collisions). see also [member right_barrier]
@export var left_barrier := true
## Right barrier? (does not change collisions). see also [member left_barrier]
@export var right_barrier := true
## Barrier width
@export var barrier_width := 4.0
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
## Does the track loop around?
@export var is_loop := true
## Offset the entire track
@export var offset := Vector3.UP
@export_group("Race")
## Num laps, 1 = go to finish and done
@export var laps := 1
@export_subgroup("Checkpoints")
## Place the path offsets of checkpoint locations in this array
@export var checkpoints: Array[float] = []
## The checkpoint scene
@export var checkpoint_scene: PackedScene = preload("res://scenes/ring_checkpoint.tscn")
## How much to scale each checkpoint
@export var checkpoint_scale := Vector3.ONE
@export var checkpoint_needs_collision := false
@export_subgroup("Finish")
## Finish (or lap cp) location in path offset
@export var finish_location: float = 0.0
## The finish scene
@export var finish_scene: PackedScene = preload("res://scenes/ring_finish.tscn")
## How much to scale the finish
@export var finish_scale := Vector3.ONE
@export var finish_needs_collision := false
@export_subgroup("Start")
## Start location in path offset (unused if [member laps] > 1)
@export var start_location: float = 0.0
## Start scene (disregarded if [member laps] > 1)
@export var start_scene: PackedScene = preload("res://scenes/ring_start.tscn")
## How much to scale the start (see above)
@export var start_scale := Vector3.ONE
@export var start_needs_collision := false

