@icon("res://ui/assets/block.png")
extends FileItem
class_name WeakLink

@export var scene: PackedScene
@export var material: BaseMaterial3D
@export var texture: Texture2D
enum Type { Scene, Material, Texture }
var type: Type:
	get:
		if scene != null:
			return Type.Scene
		elif material != null:
			return Type.Material
		elif texture != null:
			return Type.Texture
		@warning_ignore("assert_always_false")
		assert(false, "no resource available")
		return Type.Scene # smh

func hash_s() -> PackedByteArray:
	var item: PackedByteArray
	match type:
		Type.Scene: item = var_to_str(scene._bundled).to_ascii_buffer()
		Type.Material: item = var_to_str(material).to_ascii_buffer()
		Type.Texture: item = texture.get_image().get_data()
	return Thumbnail.hash_b(item)
