extends Button

@onready var hist: UndoRedo = owner.history
@onready var editor: TrackEditor = owner

func _ready() -> void:
	editor.selection_changed.connect(func(nodes: Array[Block]): disabled = nodes.size() == 0)

func _pressed() -> void:
	hist.create_action("delete %d nodes" % editor.selected.size())
	for node in editor.selected:
		var tobj := editor.tobj_from_node(node)
		hist.add_do_method(%view.remove_obj.bind(tobj, node))
		hist.add_undo_reference(node)
		hist.add_undo_method(%view.add_obj.bind(tobj, node))
	hist.commit_action()
	disabled = true
