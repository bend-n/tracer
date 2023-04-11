extends Button

@onready var hist: UndoRedo = owner.history

const icons: PackedStringArray = ['󰆓', '󰽂', '󱣪']
var unsaved := false:
	set(un):
		unsaved = un
		text = icons[int(un)]

func _on_pressed() -> void:
	var data := (owner as TrackEditor).get_trackdata()
	if FileAccess.file_exists(Globals.TRACKS % data.name):
		pass
	data.save(Globals.TRACKS % data.name)
	unsaved = false

func _ready() -> void:
	hist.version_changed.connect(func(): unsaved = true)
