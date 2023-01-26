extends RichTextLabel

@export var car: Node3D

# assumes 6 gear + rev
const F_STRING = "[center]  [b]%s[/b][/center]"
const GEARS: PackedStringArray = ["[color=#4682b4]N[/color]", "1", "2", "3", "4", "5", "6", "[color=#d84341]R[/color]"]

# func _process(_delta: float) -> void:
# 	text = F_STRING % GEARS[car.current_gear]
