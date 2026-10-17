class_name AbilityData
extends Resource

@export var ability_id: String = ""
@export var ability_name: String = ""
@export var is_unlocked: bool = false
@export var cooldown_time: float = 1.0
@export var stamina_cost: float = 0.0

# Internal runtime state
var current_cooldown: float = 0.0

func start_cooldown() -> void:
	current_cooldown = cooldown_time

func tick_cooldown(delta: float) -> void:
	if current_cooldown > 0.0:
		current_cooldown = max(current_cooldown - delta, 0.0)

func is_ready() -> bool:
	return is_unlocked and current_cooldown <= 0.0