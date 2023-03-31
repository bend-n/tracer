@icon("res://ui/assets/block.png")
extends FileItem
class_name WeakLink

@export var scene: PackedScene
@export var material: BaseMaterial3D
@export var texture: Texture
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
