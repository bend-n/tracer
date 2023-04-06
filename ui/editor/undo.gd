extends Button

@onready var hist: UndoRedo = owner.history

func _pressed() -> void:
	owner.reset_selected()
	hist.undo()

func _ready() -> void:
	hist.version_changed.connect(
		func():
			disabled = !hist.has_undo()
	)
