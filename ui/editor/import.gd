extends Button

signal import(trck: TrackResource)

var trck: TrackResource = null

func _process(_delta: float) -> void:
	if Engine.get_process_frames() % 30 == 0 and is_visible_in_tree():
		trck = EditorMarshalling.s2td(DisplayServer.clipboard_get())
		disabled = trck == null

func _pressed() -> void:
	import.emit(trck)

