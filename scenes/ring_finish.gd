extends Finish

func _ready() -> void:
    if not needs_collision:
        $Ring/Collision.queue_free()
