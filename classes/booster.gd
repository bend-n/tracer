@tool
extends Platform3D
class_name Booster

## Reset the animation
func sync() -> void:
	%animator.seek(0, true)
