@tool
#@icon("res://ui/assets/block.png")
class_name WeakLink
extends FileItem

var scene: PackedScene:
	set(s):
		scene = s; notify_property_list_changed()
var material: int = 0:
	set(m): material = m; notify_property_list_changed()
var material_color: Color
var texture: Texture2D:
	set(t): texture = t; notify_property_list_changed()
enum Type { Scene, Material, Texture }
var type: Type:
	get:
		if scene != null:
			return Type.Scene
		elif material != 0:
			return Type.Material
		elif texture != null:
			return Type.Texture
		@warning_ignore("assert_always_false")
		assert(false, "no resource available")
		return Type.Scene # smh

func _get_property_list() -> Array:
	var unset := not scene and not material and not texture
	return [
		{ "name": "scene", "type": TYPE_OBJECT, "usage": PROPERTY_USAGE_DEFAULT if unset || scene != null else PROPERTY_USAGE_NO_EDITOR, "hint": PROPERTY_HINT_RESOURCE_TYPE, "hint_string": "PackedScene" },
		{ "name": "material", "type": TYPE_INT, "usage": PROPERTY_USAGE_DEFAULT if unset || material != null else PROPERTY_USAGE_NO_EDITOR, "hint": PROPERTY_HINT_LAYERS_2D_RENDER },
		{ "name": "material_color", "type": TYPE_COLOR, "usage": PROPERTY_USAGE_DEFAULT if material != null else PROPERTY_USAGE_NO_EDITOR, "hint": PROPERTY_HINT_RESOURCE_TYPE },
		{ "name": "texture", "type": TYPE_OBJECT, "usage": PROPERTY_USAGE_DEFAULT if unset || texture != null else PROPERTY_USAGE_NO_EDITOR, "hint": PROPERTY_HINT_RESOURCE_TYPE, "hint_string": "Texture2D" },
	]

func hash_s() -> PackedByteArray:
	var item: PackedByteArray
	match type:
		Type.Scene: item = var_to_str(scene._bundled).to_ascii_buffer()
		Type.Material: item = [material]
		Type.Texture: item = texture.get_image().get_data()
	return Thumbnail.hash_b(item)
