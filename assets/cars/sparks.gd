extends GPUParticles3D

func _ready() -> void:
	get_tree().create_timer(lifetime+.5).timeout.connect(queue_free)
