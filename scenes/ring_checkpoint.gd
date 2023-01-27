extends CheckPoint

func _ready() -> void:
    if not needs_collision:
        $Ring/Collision.queue_free()

func _on_player_entered(_body: Node3D) -> void:
    print("player entered!")
    player_entered.emit()
