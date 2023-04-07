extends Button

@onready var hist: UndoRedo = owner.history
@onready var editor: TrackEditor = owner

func _ready() -> void:
	editor.selection_changed.connect(func(nodes: Array[TrackObject]):
		for node in nodes:
			if node.live_node.get_wall_mode() & Block.WALL_MODE_LEFT || node.live_node.get_wall_mode() & Block.WALL_MODE_RIGHT:
				disabled = false
				return
		disabled = true
	)

func _pressed() -> void:
	var tool: WallTool = preload("res://ui/editor/wall_tool.tscn").instantiate()
	tool.hist = hist
	add_child(tool)
	tool.init(editor.selected)
	tool.close_requested.connect(tool.queue_free)
