extends Button

@onready var editor: TrackEditor = owner

var node: Block

func _ready() -> void:
	editor.selection_changed.connect(func(nodes: Array[Block]): disabled = nodes.size() == 0)

func _pressed() -> void:
	var f := editor.tobj_from_node(node).link
	match f.type:
		WeakLink.Type.Scene:
			var thumb: Texture2D = Items.get_thumb(f)[0]
			force_drag(
				f,
				preload("res://ui/editor/block_dragdrop_preview.tscn")
					.instantiate()
					.init(thumb)
			)
		_: push_error("this cannot be")
