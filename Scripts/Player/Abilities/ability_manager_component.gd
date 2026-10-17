# AbilityManagerComponent.gd
class_name AbilityManagerComponent
extends Node

signal ability_unlocked(ability_id: String)
signal cooldown_started(ability_id: String, duration: float)

@export var player: Player

# Map of ability_id -> AbilityComponent
var abilities: Dictionary = {}

func _ready() -> void:
	# Automatically register any AbilityComponent attached as a child node
	for child in get_children():
		if child is AbilityComponent and child.data:
			abilities[child.data.ability_id] = child

## Attempts to use an ability by its ID
func trigger_ability(ability_id: String) -> bool:
	if not abilities.has(ability_id):
		push_warning("AbilityManager: Ability '%s' not registered." % ability_id)
		return false
	
	var ability: AbilityComponent = abilities[ability_id]
	if ability.execute(player):
		cooldown_started.emit(ability_id, ability.data.cooldown_time)
		return true
	
	return false

## Unlocks an ability at runtime (e.g., after picking up an item or leveling up)
func unlock_ability(ability_id: String) -> void:
	if abilities.has(ability_id):
		abilities[ability_id].data.is_unlocked = true
		ability_unlocked.emit(ability_id)
		print("Ability unlocked: ", ability_id)

func is_ability_ready(ability_id: String) -> bool:
	if abilities.has(ability_id):
		return abilities[ability_id].can_use()
	return false

func get_cooldown_remaining(ability_id: String) -> float:
	if abilities.has(ability_id):
		return abilities[ability_id].data.current_cooldown
	return 0.0