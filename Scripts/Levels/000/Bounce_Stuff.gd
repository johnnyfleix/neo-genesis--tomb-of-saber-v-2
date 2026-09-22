extends Area2D

var player: Player


func _physics_process(_delta: float) -> void:
    if player and Input.is_action_just_pressed("jump"):
        player.jump_component.jump(player)
        player.velocity.y -= 90


func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("Stock") and body is Player:
        player = body


func _on_body_exited(body: Node2D) -> void:
    if body == player:
        #await get_tree().create_timer(0.3).timeout
        player = null