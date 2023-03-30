extends ItemList
@export var t: Tree

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

func open_dir(dir: DirRes):
	clear()
	selected = dir
	for file in dir.files:
		add_item(file.resource_name, icon_table[file.type if file is WeakLink else -1])

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
