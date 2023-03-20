extends PanelContainer
class_name TrackEditor

@export var group: ButtonGroup

enum Mode { Select, Move, Rotate, Scale }
var mode: Mode
var selected: Node
signal make_gizmo(mode: Mode)

func _ready() -> void:
	group.pressed.connect(
		func pressed(b: Button) -> void:
			mode = Mode[b.name.to_pascal_case()]
			make_gizmo.emit(mode)
			print("mode changed! %s" % mode)
	)

func _on_selected_node(node: Node3D) -> void:
	if selected == node:
		return
	selected = node
	mode = Mode.Select
	group.get_buttons()[mode].button_pressed = true
	print("object: %s selected! mode: %s" % [node, mode])
	make_gizmo.emit(mode)
