extends Resource
class_name WeakLink

@export var scene: PackedScene
@export var mesh: Mesh
@export var material: BaseMaterial3D
@export var texture: Texture
enum Type { Mesh, ArrayMesh, Scene, Material, Texture }
@export var type: Type;
@export_group("array mesh propertys")
@export var vertices: PackedVector3Array
@export var primitive_type: Mesh.PrimitiveType = Mesh.PRIMITIVE_TRIANGLES
