@tool
extends Tree

@export_dir var root_dir: String

func _ready() -> void:
	var root := create_item();
	populate(root_dir, root)


func populate(path: String, parent: TreeItem):
	var dir := DirAccess.open(path)
	if dir == null:
		printerr("Failed to open directory at %s" % path)
		return

	dir.list_dir_begin()

	var file_name := dir.get_next()
	while not file_name.is_empty():
		var full_path := "%s/%s" % [dir.get_current_dir(), file_name]
		if dir.current_is_dir():
			var item := create_item(parent)
			item.set_text(0, file_name)
			item.set_meta(&"full_path", full_path)
			populate(full_path, item)
		else: pass # we dont do files here
		file_name = dir.get_next()

