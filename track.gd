extends Resource
class_name TrackResource
## Width of road
@export var track_width = 17.0
## Distance between rails and road
@export var rail_distance = 3.0
## Support base width
@export var lower_support_width = 15.0
## Height of supports
@export var support_height = 8.0
## Track curve
@export var track: Curve3D = null
## Left barrier? (does not change collisions). see also [member right_barrier]
@export var left_barrier = true
## Right barrier? (does not change collisions). see also [member left_barrier]
@export var right_barrier = true