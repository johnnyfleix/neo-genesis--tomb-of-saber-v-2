extends Node

var player_detected: bool = false
var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if player_detected:
		print("Player detected")
		allow_jump()
		if player.just_jumped:
			player.dash_comp.add_charges(1)
			player.just_jumped = false
			return


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_detected = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_detected = false

func allow_jump() -> void:
	player = get_tree().get_first_node_in_group("player")
	player.grant_jump()
