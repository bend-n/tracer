extends ItemList
@export var t: Tree

var weak_links: Array = []
@export var world: SubViewport # TODO: make this use drag and drop
@onready var history: UndoRedo = owner.history

signal selected_node(node: Node3D)
signal dir_selected()
signal created(object: TrackObject)
signal remove_tobj(tobj: TrackObject                               )

const icon_table = {
	WeakLink.Type.Scene: preload("res://ui/assets/block.png"),
	WeakLink.Type.Material: preload("res://ui/assets/material.png"),
	-1: preload("res://ui/assets/folder.png")
}

func fs_dir_selected() -> void:
	open_dir(t.get_selected().get_meta(&"full_path"))

func open_dir(path: String):
	clear()
	weak_links.clear()
	var dir := DirAccess.open(path)
	dir.list_dir_begin()

	var file_name := dir.get_next()
	while not file_name.is_empty():
		if dir.current_is_dir():
			weak_links.append(path.path_join(file_name))
		else:
			weak_links.append(load(path.path_join(file_name)))
		add_item(file_name.replacen(".tres", ""), icon_table[weak_links[-1].type if weak_links[-1] is WeakLink else -1])
		file_name = dir.get_next()

func on_selected(index: int) -> void:
	if not weak_links[index] is WeakLink:
		clear()
		dir_selected.emit()
		open_dir(weak_links[index])
		return
	var weak_link: WeakLink = weak_links[index]
	make_obj(weak_link)

func make_obj(link: WeakLink):
	match link.type:
		WeakLink.Type.Scene:
			var scn := link.scene
			var selected = scn.instantiate() as Node3D
			if selected.get_script() != null:
				selected.editor = true
			var collider: PhysicsBody3D = selected if selected is PhysicsBody3D else selected.collision
			collider.input_event.connect(node_input.bind(selected))
			var obj := TrackObject.new(scn, selected)
			obj.set_meta(&"id", len((owner as TrackEditor).objects))
			history.create_action("add block");
			history.add_do_method(add_obj.bind(obj, selected))
			history.add_do_reference(selected)
			history.add_undo_method(remove_obj.bind(obj, selected))
			var origin := world.get_camera_3d().project_position(world.size / 2, 50)
			if owner.snapping:
				origin = origin.snapped(Vector3.ONE * 10) # snap it
			history.add_do_property(selected, &"global_transform", Transform3D(Basis(), origin))
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

