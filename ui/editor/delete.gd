extends Button

@onready var hist: UndoRedo = owner.history

func _on_items_selected_node(node: Node) -> void:
	disabled = node == null

func _pressed() -> void:
	var tobj := (owner as TrackEditor).tobj_from_node(owner.selected)
	hist.create_action("delete")
	hist.add_do_method(%items.remove_obj.bind(tobj, owner.selected))
	hist.add_undo_reference(owner.selected)
	hist.add_undo_method(%items.add_obj.bind(tobj, owner.selected))
	hist.commit_action()
	disabled = true
