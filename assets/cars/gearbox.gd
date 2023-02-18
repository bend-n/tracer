extends Node

@onready var shift_1 := $Shift1 as AudioStreamPlayer

func _on_sedan_shifted() -> void:
	shift_1.play()
