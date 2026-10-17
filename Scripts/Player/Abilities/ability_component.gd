# AbilityComponent.gd
class_name AbilityComponent
extends Node

signal ability_activated(ability_name: String)
signal ability_failed(reason: String)

@export var data: AbilityData

func _process(delta: float) -> void:
	if data:
		data.tick_cooldown(delta)

## Override in child scripts (e.g. DashAbility.gd)
func execute(_user: Player) -> bool:
	if not can_use():
		return false
	
	data.start_cooldown()
	ability_activated.emit(data.ability_name)
	return true

func can_use() -> bool:
	if not data:
		push_error("AbilityComponent: Missing AbilityData resource!")
		return false
	if not data.is_unlocked:
		ability_failed.emit("locked")
		return false
	if data.current_cooldown > 0.0:
		ability_failed.emit("cooldown")
		return false
	return true