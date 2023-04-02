extends Resource
class_name TrackObject

var base_scene: PackedScene
var live_node: Node3D
var material: Material
var transform: Transform3D
var link: WeakLink

func _init(p_base: PackedScene, p_live: Node, p_link: WeakLink) -> void:
	link = p_link
	base_scene = p_base
	live_node = p_live

func exprt() -> Dictionary:
	@warning_ignore("incompatible_ternary")
	return {
		# no objects: object = code execution = rm -rf ~
		material = (live_node.mesh as MeshInstance3D).get_active_material(0).resource_path if live_node.mesh != null else null,
		base_scene = base_scene.resource_path,
		transform = live_node.global_transform,
	}

func exprt_imported() -> Dictionary:
	return {
		material = material.resource_path,
		base_scene = base_scene.resource_path,
		transform = transform
	}

static func from_d(d: Dictionary) -> TrackObject:
	var o := TrackObject.new(load(d.base_scene), null, null)
	o.material = load(d.material) if d.material else null
	o.transform = d.transform
	return o

func set_live(p_live: Node):
	live_node = p_live
	# we dont need these: this information should be transfered to the live node.
	# but i pass around my tracks too much, and build them, that this will be a problem.
	# material = null
	# transform = Transform3D()


