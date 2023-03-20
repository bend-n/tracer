extends ItemList
@export var t: Tree

var real_paths: PackedStringArray = []
@export var world: SubViewport # TODO: make this use drag and drop

signal selected_node(node: Node3D)

func fs_dir_selected() -> void:
	clear()
	real_paths.clear()
	var path := t.get_selected().get_meta(&"full_path") as String
	var dir := DirAccess.open(path)
	dir.list_dir_begin()

	var file_name := dir.get_next()
	while not file_name.is_empty():
		add_item(file_name.replacen(".tres", ""), get_theme_icon(&"File"))
		real_paths.append(path.path_join(file_name))
		file_name = dir.get_next()

func on_selected(index: int) -> void:
	var weak_link: WeakLink = load(real_paths[index])
	if weak_link == null: # directory
		pass
	else:
		match weak_link.type:
			WeakLink.Type.Scene:
				var scn := weak_link.scene
				var selected = scn.instantiate() as Node3D
				selected.editor = true
				world.add_child(selected)
				selected.global_position = world.get_camera_3d().project_position(world.size / 2, 50).snapped(Vector3.ONE * 10) # put it forth
				selected.look_at(world.get_camera_3d().global_position)
				selected.global_rotation = selected.global_rotation.snapped(Vector3.ONE * 90)
				(selected.collision as PhysicsBody3D).input_event.connect((
				## i dont know how to use unbinds in signals connected in code
				func(_c: Node, e: InputEvent, _p: Vector3, _n: Vector3, _s: int, node: Node3D):
					if is_left_click(e):
						selected_node.emit(node)
				).bind(selected))
				print("instantiated scn %s" % weak_link.scene.resource_path)

func is_left_click(e: InputEvent) -> bool:
	return (
		e is InputEventMouseButton
		and e.is_pressed()
		and e.button_index == MOUSE_BUTTON_LEFT
	)

## if the floor gets picked, that means the ray didnt hit anything else, so deselect the current selected node
func _on_floor_input_event(_c: Node, e: InputEvent) -> void:
	if is_left_click(e):
		selected_node.emit(null)
