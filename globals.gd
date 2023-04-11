extends Node
class_name Utils

var playing: TrackResource
var editing: TrackResource
var ghost: GhostData
const SAVES := "user://ghosts/%s.ghost"
const TRACKS := "user://player data/tracks/%s.track"
const THUMBS := "user://thumbs/%s.thumb"
const DEFAULT_EDITOR_LAYER := 0x80000000
const GIZMO_LAYER := 0x40000000
const GIZMO_LAYER_I := 31
const SNAP := Vector3(10, 2.5, 10)
var builtin_tracks: Array[TrackResource] = []
