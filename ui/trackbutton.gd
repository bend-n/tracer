extends Control
class_name TrackButton

const trackloader_scn = preload("res://scenes/track.tscn")
const thumbnail_path = "user://%s.thumb"

signal play
signal watch

func init(t: TrackResource, g: GhostData) -> void:
	%name.text = t.name
	if g == null:
		%watch.hide()
		%time.text = "no time set"
	else:
		%time.text = GameTimer.format_precise(g.time)
	var p: String = thumbnail_path % t.name
	if FileAccess.file_exists(p) and Time.get_unix_time_from_system() - FileAccess.get_modified_time(p) < 400000: # ~5days
		print("loading thumb")
		var f := FileAccess.open(p, FileAccess.READ)
		var img := Image.new()
		var e := img.load_png_from_buffer(f.get_buffer(f.get_length()))
		if e != OK:
			print("error: ", e)
			return
		(%thumb as TextureRect).texture = ImageTexture.create_from_image(img)
	else:
		print("making thumb")
		%port.add_child(IntroCam.new(t, null))
		var trackloader: TrackLoader = trackloader_scn.instantiate()
		trackloader.track = t
		%port.add_child(trackloader)
		await RenderingServer.frame_post_draw
		trackloader.queue_free()
		var img: Image = %port.get_texture().get_image()
		img.save_png(p)
		(%thumb as TextureRect).texture = ImageTexture.create_from_image(img)



