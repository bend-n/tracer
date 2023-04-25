extends Button

@export var help_scn: PackedScene
var help: Window

func _pressed() -> void:
	if not is_instance_valid(help):
		help = help_scn.instantiate()
		help.close_requested.connect(help.queue_free)
		add_child(help)
