extends Button

@onready var editor: TrackEditor = owner

func _on_selection_changed(nodes: Array[TrackObject]):
	disabled = nodes.size() == 0

func _pressed() -> void:
	var links: Array[FileItem] = [] # map doesnt work with typed arrays
	var selected_dup: Array[TrackObject] = []
	var positions: PackedVector3Array = []
	selected_dup.resize(len(editor.selected))
	positions.resize(len(editor.selected))
	links.resize(len(editor.selected))
	var first_p := editor.selected[0].live_node.global_position
	for i in len(editor.selected):
		positions[i] = editor.selected[i].live_node.global_position - first_p
		links[i] = editor.selected[i].link
		selected_dup[i] = editor.selected[i].dup()
	force_drag(
		[selected_dup, positions],
		%items.make_drag_preview(Items.get_thumbs(links))
	)
