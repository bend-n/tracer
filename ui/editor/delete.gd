extends Button

func _on_items_selected_node(node: Node) -> void:
	disabled = node == null

func _pressed() -> void:
	disabled = true
