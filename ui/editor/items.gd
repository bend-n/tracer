extends ItemList

var selected: DirRes
@onready var world: SubViewport = %port # TODO: make this use drag and drop
@onready var history: UndoRedo = owner.history

signal selected_node(node: Node3D)
signal dir_selected(i: int)
signal created(object: TrackObject)
signal remove_tobj(tobj: TrackObject)

const icon_table = {
	WeakLink.Type.Scene: preload("res://ui/assets/block.png"),
	WeakLink.Type.Material: preload("res://ui/assets/material.png"),
	-1: preload("res://ui/assets/folder.png")
}

var thread: Thread = Thread.new()

func open_dir(dir: DirRes):
	clear()
	selected = dir
	var needing_thumbs := []
	for i in dir.files.size():
		var file := dir.files[i]
		var thumb: Texture2D = null
		if file is WeakLink:
			thumb = icon_table[file.type]
			if file.type == WeakLink.Type.Scene:
				var img := Thumbnail._load(Globals.THUMBS % file.resource_name, Thumbnail.hash_b(var_to_bytes(file)))
				if img:
					thumb = ImageTexture.create_from_image(img)
				else:
					needing_thumbs.append([i, file])
		else:
			thumb = icon_table[-1]
		add_item(file.resource_name, thumb)
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
					var floor := preload("res://scenes/floor.tscn").instantiate()
					floor.position.y -= 5
					n.add_child(floor)
					var camera := Camera3D.new()
					camera.position = Vector3(-8, 10,-8)
					camera.position += camera.transform.basis.z * 2
					camera.rotation = Vector3(-PI/4, -PI/1.35, 0)
					var t := await Thumbnail.create_thumb(self, n, camera)
					var e := Thumbnail.save(t, Globals.THUMBS % file.resource_name, Thumbnail.hash_b(var_to_bytes(file)))
					if e != OK:
						push_error("err when thumbnailing %s: %d" % [file.resource_name, e])
					if item_count > need[0]: # may have switched dirs
						set_item_icon(need[0], ImageTexture.create_from_image(t))
	)

func on_selected(index: int) -> void:
	var f := selected.files[index]
	if not f is WeakLink:
		clear()
		dir_selected.emit(index)
		open_dir(f)
		return
	make_obj(f)

func make_obj(link: WeakLink):
	match link.type:
		WeakLink.Type.Scene:
			var scn := link.scene
			var node := scn.instantiate() as Node3D
			if node.get_script() != null:
				node.editor = true
			var collider: PhysicsBody3D = node if node is PhysicsBody3D else node.collision
			collider.input_event.connect(node_input.bind(node))
			var obj := TrackObject.new(scn, node)
			obj.set_meta(&"id", len((owner as TrackEditor).objects))
			history.create_action("add block");
			history.add_do_method(add_obj.bind(obj, node))
			history.add_do_reference(node)
			history.add_undo_method(remove_obj.bind(obj, node))
			var origin := world.get_camera_3d().project_position(world.size / 2, 50)
			if owner.snapping:
				origin = origin.snapped(Vector3.ONE * 10) # snap it
			history.add_do_property(node, &"global_transform", Transform3D(Basis(), origin))
			history.commit_action()

func add_obj(o: TrackObject, n: Node):
	world.add_child(n)
	created.emit(o)

func remove_obj(obj: TrackObject, n: Node):
	emit_signal(&"remove_tobj", obj)
	world.remove_child(n)

func is_left_click(e: InputEvent) -> bool:
	return (
		e is InputEventMouseButton
		and e.is_pressed()
		and e.button_index == MOUSE_BUTTON_LEFT
	)

## if the floor gets picked, that means the ray didnt hit anything else, so deselect the current selected node
func _on_floor_input_event(_c: Node, e: InputEvent, _p: Vector3, _n: Vector3, _s: int) -> void:
	if is_left_click(e):
		selected_node.emit(null)

## i dont know how to use unbinds in signals connected in code
func node_input(_c: Node, e: InputEvent, _p: Vector3, _n: Vector3, _s: int, node: Node3D):
	if is_left_click(e):
		selected_node.emit(node)
