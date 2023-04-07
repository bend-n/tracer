extends Control
class_name DragDropPreview

var blocks: Array[Block] = []
var objects: Array[Block]
var offsets: PackedVector3Array = []
var offsets_unset := false
var cam: Camera3D
var previews: Node3D

func get_columns(x: int) -> int:
	return floori(sqrt(x))

func init(textures: Array[Texture2D], p_cam: Camera3D):
	cam = p_cam
	var columns := get_columns(textures.size())
	%grid.columns = columns
	for i in columns * columns:
		var t_rect := TextureRect.new()
		t_rect.size_flags_horizontal = SIZE_EXPAND
		t_rect.size_flags_vertical = SIZE_EXPAND
		t_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t_rect.texture = textures[i]
		@warning_ignore("integer_division")
		t_rect.custom_minimum_size = Vector2(64/columns, 64/columns)
		%grid.add_child(t_rect)
	return self

func _ready() -> void:
	await get_tree().physics_frame
	var data = get_viewport().gui_get_drag_data()
	if (
		data is Array
		and data.size() == 2
		and data[0] is Array[TrackObject]
		and data[1] is PackedVector3Array
		and data[0].size() == data[1].size()
	):
		mkobjs(data[0])
		offsets = data[1]
	elif data is Array[TrackObject]:
		mkobjs(data)
		offsets_unset = true
	tree_exiting.connect(cleanup)

func cleanup() -> void:
	for block in blocks: block.queue_free()

func mkobjs(objs: Array[TrackObject]):
	for obj in objs:
		var block: Block = obj.create()
		block.editor = true
		add_child(block)
		block.hide()
		blocks.append(block)

func over_viewport():
	%panel.hide()
	for block in blocks: block.show()

func viewport_event(e: InputEvent) -> void:
	if e is InputEventMouse:
		position_blocks(e.position)

func position_blocks(mp: Vector2):
	var at_position := cam.project_position(mp, 50)
	for i in len(blocks):
		blocks[i].global_position = (
			(offsets[i] + at_position)
				if not offsets_unset
			else at_position
		).snapped(Globals.SNAP)

func exit_viewport() -> void:
	%panel.show()
	for block in blocks:
		block.hide()
