extends Finish

func _ready() -> void:
		if not needs_collision:
				$Collision.queue_free()
