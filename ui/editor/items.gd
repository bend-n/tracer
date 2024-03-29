extends ItemList
class_name Items

var selected: DirRes

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

## doesnt care about failures & processes multiple files.
## the size of the output may not equal the size of the input,
## as it tries to not create duplicates.
static func get_thumbs(files: Array[FileItem]) -> Array[Texture2D]:
	var files_uniq := []
	for file in files:
		if not files_uniq.has(file):
			files_uniq.append(file)
	var output: Array[Texture2D] = []
	output.resize(len(files_uniq))
	for i in len(files_uniq):
		var thumb: Texture2D = icon_table[-1]
		if files_uniq[i] is WeakLink:
			thumb = icon_table[files_uniq[i].type]
			if files[i].type == WeakLink.Type.Scene:
				var hsh: PackedByteArray = files_uniq[i].hash_s()
				var img := Thumbnail._load(Globals.THUMBS % files_uniq[i].resource_name, hsh)
				if img:
					thumb = ImageTexture.create_from_image(img)
				output[i] = thumb
	return output

func open_dir(dir: DirRes):
	clear()
	selected = dir
	var needing_thumbs := []
	for i in dir.files.size():
		var file := dir.files[i]
		var thumb := Items.get_thumb(file)
		if thumb.size() > 1:
			needing_thumbs.append([i, file, thumb[-1]])
		set_item_tooltip(add_item(file.resource_name, thumb[0]), file.description)
	if thread.is_started():
		thread.wait_to_finish()
	thread.start(func():
		for need in needing_thumbs:
			var file: WeakLink = need[1]
			match file.type:
				WeakLink.Type.Scene:
					var n: Block = file.scene.instantiate()
					n.making_thumbnail = true
					n.add_child(preload("res://scenes/sun.tscn").instantiate())
					var ground := preload("res://scenes/floor.tscn").instantiate()
					ground.position.y -= 5
					n.add_child(ground)
					var world := World3D.new()
					world.environment = preload("res://default_env.tres")
					var t := await Thumbnail.create_thumb(self, n, Vector2(64,64), world)
					var e := Thumbnail.save(t, Globals.THUMBS % file.resource_name, need[2])
					if e != OK:
						push_error("err when thumbnailing %s: %d" % [file.resource_name, e])
					if item_count > need[0]: # may have switched dirs
						set_item_icon(need[0], ImageTexture.create_from_image(t))
	, Thread.PRIORITY_LOW)

func _get_drag_data(at_position: Vector2) -> Variant:
	var index := get_item_at_position(at_position)
	var f := selected.files[index]
	if not f is WeakLink:
		return null
	set_drag_preview(make_drag_preview([get_item_icon(index)]))
	match f.type:
		WeakLink.Type.Scene:
			var objects: Array[TrackObject] = [TrackObject.new(BlockMap.find(f.scene), null, f)]
			return objects
		WeakLink.Type.Material:
			return f
	return null

func make_drag_preview(textures: Array[Texture2D]) -> Control:
	var preview: DragDropPreview = preload("res://ui/editor/block_dragdrop_preview.tscn").instantiate().init(textures, %cam)
	%view.gui_input.connect(preview.viewport_event)
	%view.mouse_entered.connect(preview.over_viewport)
	%view.mouse_exited.connect(preview.exit_viewport)
	%view.depth_changed.connect(preview.depth_changed)
	preview.depth = %view.depth
	if Rect2(Vector2.ZERO, %port.size).has_point(%port.get_mouse_position()):
		get_tree().physics_frame.connect(func():
			preview.over_viewport()
		, CONNECT_ONE_SHOT | CONNECT_DEFERRED)
	return preview


func _on_tree_exiting() -> void:
	if thread.is_started():
		thread.wait_to_finish()
