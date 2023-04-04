extends Button

@onready var editor: TrackEditor = owner

func _ready() -> void:
	editor.selection_changed.connect(func(nodes: Array[TrackObject]): disabled = nodes.size() == 0)

func _pressed() -> void:
	var positions: PackedVector3Array
	positions.resize(len(editor.selected))
	var links: Array[FileItem] # map doesnt work with typed arrays
	links.resize(len(editor.selected))
	var first_p := editor.selected[0].live_node.global_position
	for i in len(editor.selected):
		positions[i] = editor.selected[i].live_node.global_position - first_p
		links[i] = editor.selected[i].link
	for o in editor.selected:
		links.append(o.link)
	force_drag(
		[editor.selected, positions],
		%items.make_drag_preview(Items.get_thumbs(links))
	)
