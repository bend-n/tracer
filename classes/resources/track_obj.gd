extends Resource
class_name TrackObject

var base_scene: int = -1
var live_node: Block
var material: int
var walls: int
var transform: Transform3D
var link: WeakLink

func _init(p_base: int, p_live: Node, p_link: WeakLink) -> void:
	link = p_link
	base_scene = p_base
	set_live(p_live)

func exprt() -> Dictionary:
	save()
	return {
		m = material,
		b = base_scene,
		t = transform,
		w = walls,
	}

static func from_d(d: Dictionary) -> TrackObject:
	var o := TrackObject.new(d.b, null, null)
	o.material = d.get("m", 0)
	o.transform = d.t
	o.walls = d.w
	return o

func save() -> void:
	if is_instance_valid(live_node):
		transform = live_node.transform
		walls = live_node.has_walls()
		material = live_node.mat

func delete_live() -> void:
	save()
	live_node = null

## [param p_live] may or may not be in the tree
func set_live(p_live: Block):
	live_node = p_live
	# we dont need these: this information should be transfered to the live node.
	# but i pass around my tracks too much, and build them, that this will be a problem.
	# material = null
	# transform = Transform3D()

## @constant
func create(is_editor := false) -> Node3D:
	var node: Block = BlockMap.map[base_scene].instantiate()
	node.editor = is_editor
	node.global_transform = transform
	node.ready.connect(node.make_walls.bind(walls))
	if material != 0:
		node.ready.connect(node.set_mat.bind(material))
	return node

## a more efficient [code]TrackObject.from_d(obj.exprt())[/code].
func dup() -> TrackObject:
	var tobj := TrackObject.new(base_scene, null, link)
	save()
	tobj.transform = transform
	tobj.walls = walls
	tobj.material = material
	return tobj

func name() -> String:
	if link:
		return link.resource_name
	if is_instance_valid(live_node):
		return live_node.name
	if base_scene != -1:
		return BlockMap.map[base_scene].resource_path.get_file().get_basename()
	return "unnamed"

func _to_string() -> String:
	return "TrackObject<%s>" % name()
