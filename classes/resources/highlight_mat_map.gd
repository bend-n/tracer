extends Resource
class_name MatMap

static func get_highlight(m_id: int) -> BaseMaterial3D:
	return load("%s_highlight.%s" % [map[m_id].resource_path.get_basename(), map[m_id].resource_path.get_extension()])

const map := {
	1: preload("res://assets/mats/platform.material"),
	2: preload("res://assets/mats/road.tres"),
	4: preload("res://assets/mats/grass.tres"),
	8: preload("res://assets/mats/ring_checkpoint.tres"),
	16: preload("res://assets/mats/ring_finish.tres"),
	32: preload("res://assets/mats/ring_start.tres")
}
