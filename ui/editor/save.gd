extends Button

const icons: PackedStringArray = ['󰆓', '󰽂', '󱣪']
var unsaved := false:
	set(un):
		unsaved = un
		text = icons[int(un)]

func _on_pressed() -> void:
	var data := (owner as TrackEditor).to_trackdata()
	if FileAccess.file_exists(Globals.TRACKS % data.name):
		pass
	data.save(Globals.TRACKS % data.name)
