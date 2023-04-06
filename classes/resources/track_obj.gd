extends Resource
class_name TrackObject

var base_scene: PackedScene
var live_node: Block
#var material: Material
var has_left_wall := false
var has_right_wall := false
var transform: Transform3D:
	get:
		if live_node:
			return live_node.global_transform
		else:
			return transform
var link: WeakLink

func _init(p_base: PackedScene, p_live: Node, p_link: WeakLink) -> void:
	link = p_link
	base_scene = p_base
	live_node = p_live

func exprt() -> Dictionary:
	if live_node:
		@warning_ignore("incompatible_ternary")
		return {
			# no objects: object = code execution = rm -rf ~
#			m = (live_node.mesh as MeshInstance3D).get_active_material(0).resource_path if live_node.mesh != null else null,
			b = base_scene.resource_path,
			t = live_node.global_transform,
			r = live_node.has_right_wall(),
			l = live_node.has_left_wall(),
		}
	else:
		return exprt_imported()

func exprt_imported() -> Dictionary:
	return {
#		m = material.resource_path,
		b = base_scene.resource_path,
		t = transform,
		r = has_right_wall,
		l = has_left_wall,
	}

static func from_d(d: Dictionary) -> TrackObject:
	var o := TrackObject.new(load(d.b), null, null)
#	o.material = load(d.m) if d.m else null
	o.transform = d.t
	o.has_left_wall = d.l
	o.has_right_wall = d.r
	return o

## [param p_live] may or may not be in the tree
func set_live(p_live: Block):
	live_node = p_live
	# we dont need these: this information should be transfered to the live node.
	# but i pass around my tracks too much, and build them, that this will be a problem.
	# material = null
	# transform = Transform3D()

func create(is_editor := false) -> Node3D:
	var node: Block = base_scene.instantiate()
#	if not node is Decoration:
#		node.mesh.set_surface_override_material(0, material)
	node.editor = is_editor
	node.global_transform = transform
	node.ready.connect(func():
		if has_left_wall and node.get_wall_mode() & Block.WALL_MODE_LEFT:
			node.make_left_wall()
		if has_right_wall and node.get_wall_mode() & Block.WALL_MODE_RIGHT:
			node.make_right_wall()
	)
	return node

func _to_string() -> String:
	return "TrackObject<%s>" % link.resource_name
