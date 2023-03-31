extends Control
class_name TrackButton

const trackloader_scn = preload("res://scenes/track.tscn")

@export var button: Button
signal play
signal watch

func init(t: TrackResource, g: GhostData) -> void:
	%name.text = t.name
	if g == null:
		%watch.hide()
		%time.text = "no time set"
	else:
		%time.text = GameTimer.format_precise(g.time)
	var p: String = Globals.THUMBS % t.name
	var tex := Thumbnail._load(p, Thumbnail.hash_b(var_to_bytes(t)))
	if tex == null:
		var trackloader: TrackLoader = trackloader_scn.instantiate()
		trackloader.track = t
		tex = await Thumbnail.create_thumb(self, trackloader, IntroCam.new(t, null), Vector2i(450, 200))
		var e := Thumbnail.save(tex, p, Thumbnail.hash_f(Globals.TRACKS % t.name))
		if e != OK:
			push_error("saving thumbnail failed with error %d" % e)
	(%thumb as TextureRect).texture = ImageTexture.create_from_image(tex)
