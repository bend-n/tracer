extends ItemList
class_name Items

var selected: DirRes

signal selected_node(node: Block)
signal dir_selected(i: int)

const icon_table = {
	WeakLink.Type.Scene: preload("res://ui/assets/block.png"),
	WeakLink.Type.Material: preload("res://ui/assets/material.png"),
	-1: preload("res://ui/assets/folder.png")
}

var thread: Thread = Thread.new()

static func get_thumb(f: FileItem) -> Array:
	var thumb: Texture2D = icon_table[-1]
	if f is WeakLink:
		thumb = icon_table[f.type]
		if f.type == WeakLink.Type.Scene:
			var hsh: PackedByteArray = f.hash_s()
			var img := Thumbnail._load(Globals.THUMBS % f.resource_name, hsh)
			if img:
				return [ImageTexture.create_from_image(img)]
			else:
				return [thumb, hsh]
	return [thumb]

func open_dir(dir: DirRes):
	clear()
	selected = dir
	var needing_thumbs := []
	for i in dir.files.size():
		var file := dir.files[i]
		var thumb := Items.get_thumb(file)
		if thumb.size() > 1:
			needing_thumbs.append([i, file, thumb[-1]])
		add_item(file.resource_name, thumb[0])
	if thread.is_started():
		while thread.is_alive():
			await Engine.get_main_loop().process_frame
		thread.wait_to_finish()
	thread.start(func():
		for need in needing_thumbs:
			var file: WeakLink = need[1]
			match file.type:
				WeakLink.Type.Scene:
					var n := file.scene.instantiate()
					n.add_child(preload("res://scenes/sun.tscn").instantiate())
					var ground := preload("res://scenes/floor.tscn").instantiate()
					ground.position.y -= 5
					n.add_child(ground)
					var camera := Camera3D.new()
					camera.position = Vector3(-8, 10,-8)
					camera.position += camera.transform.basis.z * 2
					camera.rotation = Vector3(-PI/4, -PI/1.35, 0)
					var t := await Thumbnail.create_thumb(self, n, camera)
					var e := Thumbnail.save(t, Globals.THUMBS % file.resource_name, need[2])
					if e != OK:
						push_error("err when thumbnailing %s: %d" % [file.resource_name, e])
					if item_count > need[0]: # may have switched dirs
						set_item_icon(need[0], ImageTexture.create_from_image(t))
	)

func _get_drag_data(at_position: Vector2) -> Variant:
	var index := get_item_at_position(at_position)
	var f := selected.files[index]
	if not f is WeakLink:
		clear()
		dir_selected.emit(index)
		open_dir(f)
		return null
	match f.type:
		WeakLink.Type.Scene:
			set_drag_preview(
				preload("res://ui/editor/block_dragdrop_preview.tscn")
					.instantiate()
					.init(get_item_icon(index))
			)
	return f

func _on_mousecast_miss() -> void:
	selected_node.emit(null)

func _on_mousecast_hit(coll: Block) -> void:
	selected_node.emit(coll)
