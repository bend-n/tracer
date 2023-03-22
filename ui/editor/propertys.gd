@tool
extends Tree

signal name_changed(n: String)
var name_button: TreeItem

func _ready() -> void:
	var root := create_item();
	name_button = root.create_child()
	name_button.set_text(0, "name")
	name_button.set_editable(1, true)
	name_button.set_text(1, "untitled track")
	name_changed.emit(name_button.get_text(1))

func _on_item_edited() -> void:
	name_changed.emit(name_button.get_text(1))
