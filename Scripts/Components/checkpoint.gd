class_name Checkpoint
extends Area2D

signal checkpoint_activated(checkpoint_position: Vector2)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	var respawn_comp = body.find_child("RespawnComponent", true, false) as RespawnComponent
	if respawn_comp:
		respawn_comp.set_checkpoint(global_position)
		print("Checkpoint activated at: ", global_position)
		checkpoint_activated.emit(global_position)