extends Finish

func _ready() -> void:
    if not needs_collision:
        $Ring/Collision.queue_free()

func _on_player_entered(_body: Node3D) -> void:
    print("player finished!")
    player_entered.emit()
