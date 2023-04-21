extends Button

signal import(trck: TrackResource)

var trck: TrackResource = null
var last_checked: String

func _process(_delta: float) -> void:
	if last_checked != DisplayServer.clipboard_get():
		trck = EditorMarshalling.s2td(DisplayServer.clipboard_get())
		disabled = trck == null
		last_checked = DisplayServer.clipboard_get()

func _pressed() -> void:
	import.emit(trck)

