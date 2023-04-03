extends Decoration

func get_aabb():
	return $trunk.get_aabb().merge($top.get_aabb())
