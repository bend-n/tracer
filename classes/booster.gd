@tool
class_name Booster
extends Platform3D

## Reset the animation
func sync() -> void:
	%animator.seek(0, true)
