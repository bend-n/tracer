extends Button

@onready var hist: UndoRedo = owner.history
@onready var editor: TrackEditor = owner
@export var tool: WallTool

func _ready() -> void:
	tool.hist = hist
	editor.selection_changed.connect(func(nodes: Array[TrackObject]):
		for node in nodes:
			if node.live_node.get_wall_mode() & Block.WALL_MODE_LEFT || node.live_node.get_wall_mode() & Block.WALL_MODE_RIGHT:
				disabled = false
				return
		disabled = true
	)
	tool.close_requested.connect(tool.reset)

func _pressed() -> void:
	tool.init(editor.selected)
