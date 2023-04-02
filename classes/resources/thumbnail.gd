extends Object
class_name Thumbnail

@warning_ignore("shadowed_global_identifier")
static func _load(p: String, hash: PackedByteArray, error_if_hash_mismatch := true) -> Image:
	if FileAccess.file_exists(p):
		var f := FileAccess.open(p, FileAccess.READ)
		var img := Image.new()
		var buf := f.get_buffer(f.get_length())
		if buf:
			var dict: Dictionary = bytes_to_var(buf)
			var e := img.load_png_from_buffer(dict.b)
			if e != OK:
				push_error("error: ", e)
				return null
			if dict.h != hash:
				if error_if_hash_mismatch:
					push_error("error loading thumbnail %s: hash (thumbnail hash) %s != (file hash) %s" % [p, dict.h.hex_encode(), hash.hex_encode()])
				return null
			return img
	return null

static func hash_f(p: String) -> PackedByteArray:
	var file := FileAccess.open(p, FileAccess.READ)
	return hash_b(file.get_buffer(file.get_length()))

static func hash_b(b: PackedByteArray) -> PackedByteArray:
	var h := HashingContext.new()
	h.start(HashingContext.HASH_SHA1)
	h.update(b)
	return h.finish()

static func create_thumb(parent: Node, node: Node3D, cam: Camera3D, size := Vector2i(64, 64), world := World3D.new()) -> Image:
	var port := SubViewport.new()
	port.size = size
	port.msaa_3d = Viewport.MSAA_4X
	port.screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA
	port.own_world_3d = true
	port.world_3d = world
	parent.add_child(port)
	port.add_child(node)
	port.add_child(cam)
	port.render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	var img: Image = port.get_texture().get_image()
	port.queue_free()
	return img

@warning_ignore("shadowed_global_identifier")
static func save(img: Image, p: String, hash: PackedByteArray) -> Error:
	if !DirAccess.dir_exists_absolute(p.get_base_dir()):
		DirAccess.make_dir_recursive_absolute(p.get_base_dir())
	var file := FileAccess.open(p, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_buffer(var_to_bytes({ b = img.save_png_to_buffer(), h = hash }))
	return OK
