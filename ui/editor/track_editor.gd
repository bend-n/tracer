extends PanelContainer
class_name TrackEditor

@export var group: ButtonGroup

enum Mode { Select, Move, Rotate, Scale }
var mode: Mode
var selected: Node
var snapping := true
var objects: Array[TrackObject] = []
signal make_gizmo(mode: Mode)

func _ready() -> void:
	group.pressed.connect(
		func pressed(b: Button) -> void:
			mode = Mode[b.name.to_pascal_case()]
			make_gizmo.emit(mode)
	)

func _on_selected_node(node: Node3D) -> void:
	if selected == node:
		return
	selected = node
	print("object: %s selected! mode: %s" % [node, mode])
	make_gizmo.emit(mode)

func _on_snapping_toggled(button_pressed: bool) -> void:
	snapping = button_pressed

func to_trackdata() -> TrackResource:
	objects = objects.filter(func(o: TrackObject): return is_instance_valid(o.live_node))
	var data := TrackResource.new(objects)
	data.name = n
	return data

func _on_items_created(object: TrackObject) -> void:
	objects.append(object)

var n: String
func _on_propertys_name_changed(p_name: String) -> void:
	n = p_name
