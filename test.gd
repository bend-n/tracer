extends CSGBox3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	(material as StandardMaterial3D).msdf_outline_size = 50