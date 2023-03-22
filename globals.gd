extends Node

var playing: TrackResource
var ghost: GhostData
const SAVES := "user://ghosts/%s.ghost"
const TRACKS := "user://player data/tracks/%s.track"
const THUMBS := "user://thumbs/%s.thumb"
const DEFAULT_EDITOR_LAYER := 0x80000000

