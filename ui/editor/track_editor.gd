extends PanelContainer

@export var group: ButtonGroup

enum Mode { Select, Move, Rotate, Scale }
var mode: Mode
var selected: Node

func _ready() -> void:
	group.pressed.connect(
		func pressed(b: Button) -> void:
			mode = Mode[b.name.to_pascal_case()]
	)

func _on_cam_selected(object: Node) -> void:
	selected = object
