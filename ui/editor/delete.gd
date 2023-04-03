extends Button

@onready var hist: UndoRedo = owner.history

func _ready() -> void:
	%mousecast.hit.connect(hit)

func hit(nodes: Array[Block]) -> void:
	disabled = nodes.size() == 0

func _pressed() -> void:
	var tobj := (owner as TrackEditor).tobj_from_node(owner.selected)
	hist.create_action("delete")
	hist.add_do_method(%view.remove_obj.bind(tobj, owner.selected))
	hist.add_undo_reference(owner.selected)
	hist.add_undo_method(%view.add_obj.bind(tobj, owner.selected))
	hist.commit_action()
	disabled = true
