extends Resource
class_name WeakLink

@export_file var file;
enum Type { Mesh, Scene, Material, Texture }
@export var type: Type;
@export var has_needs_collision_prop: bool = false;
