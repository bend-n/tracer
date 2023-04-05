extends Resource
class_name MatMap

static func get_highlight(res: BaseMaterial3D) -> BaseMaterial3D:
	return load("%s_highlight.%s" % [res.resource_path.get_basename(), res.resource_path.get_extension()])
