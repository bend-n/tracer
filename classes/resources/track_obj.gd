extends Resource
class_name TrackObject

var base_scene: PackedScene
var live_node: Block
#var material: Material
var wall_mode: int
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
	set_live(p_live)

func exprt() -> Dictionary:
	if live_node:
		@warning_ignore("incompatible_ternary")
		return {
			# no objects: object = code execution = rm -rf ~
#			m = (live_node.mesh as MeshInstance3D).get_active_material(0).resource_path if live_node.mesh != null else null,
			b = base_scene.resource_path,
			t = live_node.global_transform,
			w = live_node.has_walls(),
		}
	else:
		return exprt_imported()

func exprt_imported() -> Dictionary:
	return {
#		m = material.resource_path,
		b = base_scene.resource_path,
		t = transform,
		w = wall_mode,
	}

static func from_d(d: Dictionary) -> TrackObject:
	var o := TrackObject.new(load(d.b), null, null)
#	o.material = load(d.m) if d.m else null
	o.transform = d.t
	o.wall_mode = d.w
	return o

## [param p_live] may or may not be in the tree
func set_live(p_live: Block):
	live_node = p_live
	if p_live:
		live_node.tree_exiting.connect(set_live.bind(null))
	# we dont need these: this information should be transfered to the live node.
	# but i pass around my tracks too much, and build them, that this will be a problem.
	# material = null
	# transform = Transform3D()

## @constant
func create(is_editor := false) -> Node3D:
	var node: Block = base_scene.instantiate()
#	if not node is Decoration:
#		node.mesh.set_surface_override_material(0, material)
	node.editor = is_editor
	node.global_transform = transform
	node.ready.connect(node.make_walls.bind(wall_mode))
	return node

## a more efficient [code]TrackObject.from_d(obj.exprt())[/code].
func dup() -> TrackObject:
	var tobj := TrackObject.new(base_scene, null, link)
	if live_node:
		tobj.transform = live_node.global_transform
		tobj.wall_mode = live_node.has_walls()
	else:
		tobj.transform = transform
		tobj.wall_mode = wall_mode
	return tobj


func _to_string() -> String:
	return "TrackObject<%s>" % link.resource_name
