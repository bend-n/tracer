@tool
extends Tree

@export var root_fs: DirRes
var selected: DirRes

signal selected_dir(d: DirRes)

func _ready() -> void:
	var root := create_item();
	populate(root_fs, root)

func populate(fs: DirRes, parent: TreeItem):
	for file in fs.files:
		if file is DirRes:
			var item := create_item(parent)
			item.set_icon(0, preload("res://ui/assets/folder.png"))
			item.set_icon_max_width(0, 24)
			item.set_text(0, file.resource_name)
			item.set_meta(&"res", file)
			item.collapsed = true
			populate(file, item)
		else: pass # we dont do files here (that responsibility goes to items)

func expand_selected() -> void:
	get_selected().collapsed = false

func _on_cell_selected() -> void:
	selected = get_selected().get_meta(&"res")
	selected_dir.emit(selected)

func _on_items_dir_selected(i: int) -> void:
	get_selected().get_child(i).select(0)
