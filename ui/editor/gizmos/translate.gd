extends Node3D

@export_node_path("Node3D") var path: NodePath = ".."
@onready var object: Node3D = get_node(path)
