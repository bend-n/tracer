extends ItemList
@export var t: Tree

var real_paths: PackedStringArray = []
@export var world: SubViewport # TODO: make this use drag and drop

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
				var scn: PackedScene = load(weak_link.file)
				var selected = scn.instantiate() as Node3D
				if weak_link.has_needs_collision_prop:
					selected.needs_collision = true
					print("need collision!")

				world.add_child(selected)
				selected.global_position = world.get_camera_3d().project_position(world.size / 2, 50).snapped(Vector3.ONE * 10) # put it forth
				selected.look_at(world.get_camera_3d().global_position)
				selected.global_rotation = selected.global_rotation.snapped(Vector3.ONE * 90)
				print("instantiated scn %s" % weak_link.file)
