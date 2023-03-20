extends Resource
class_name WeakLink

@export var scene: PackedScene
@export var material: BaseMaterial3D
@export var texture: Texture
enum Type { Scene, Material, Texture }
@export var type: Type;
