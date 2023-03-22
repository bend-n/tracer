extends Resource
class_name TrackObject

var base_scene: PackedScene
var live_node: Node3D
var material: Material
var transform: Transform3D

func _init(p_base: PackedScene, p_live: Node) -> void:
	base_scene = p_base
	live_node = p_live

func exprt() -> Dictionary:
	return {
		# no objects: object = code execution = rm -rf ~
		material = (live_node.mesh as MeshInstance3D).get_active_material(0).resource_path,
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
	var o := TrackObject.new(load(d.base_scene), null)
	o.material = load(d.material)
	o.transform = d.transform
	return o

func set_live(p_live: Node):
	live_node = p_live
	material = null
	transform = Transform3D()


