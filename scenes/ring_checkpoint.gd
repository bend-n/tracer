extends CheckPoint

func _ready() -> void:
	collision = $Collision
	super()
	if editor:
		$PlayerDetector.queue_free()
