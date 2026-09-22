extends Control

@onready var label: Label = $RemainingDash

var player: Player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		if not player:
			return
	var current_charge_int: int = player.dash_comp.current_charges
	update_counter(current_charge_int)

func update_counter(amount: int):
	label.text = str(amount)

# Rendering > Textures > VRAM compression > Import ETC2 ASTC
