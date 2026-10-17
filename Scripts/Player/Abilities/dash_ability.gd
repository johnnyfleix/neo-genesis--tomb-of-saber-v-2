class_name DashAbility
extends AbilityComponent

signal dash_started
signal dash_ended

@export_group("Dash Physics")
## Dash velocity in pixels per second
@export var dash_speed: float = 800.0
## Duration of the dash in seconds
@export var dash_duration: float = 0.2

var is_dashing: bool = false
## Tracks whether the player has their airborne dash charge available
var can_air_dash: bool = true

## Executes the fixed burst dash
func execute(user: Player) -> bool:
	if not super.can_use() or is_dashing:
		return false

	# Air Restriction Check
	if not user.is_on_floor():
		if not can_air_dash:
			return false # Already used air dash!
		
		# Consume the airborne charge
		can_air_dash = false

	data.start_cooldown()
	is_dashing = true
	dash_started.emit()
	ability_activated.emit(data.ability_name)

	var dir_x := _get_dash_direction_x(user)
	_perform_dash(user, dir_x)
	return true

## Restores the ability to dash in mid-air (called on landing, pogo hit, etc.)
func replenish_dash() -> void:
	can_air_dash = true

func _perform_dash(user: Player, dir_x: float) -> void:
	user.velocity.x = dir_x * dash_speed
	await get_tree().create_timer(dash_duration).timeout
	is_dashing = false
	dash_ended.emit()

func _get_dash_direction_x(user: Player) -> float:
	var dir_x := 0.0
	if user.input_component:
		dir_x = user.input_component.stock_horizontal
		if dir_x == 0.0:
			dir_x = user.input_component.input_horizontal
	if dir_x == 0.0:
		dir_x = 1.0 if user.scale.x > 0.0 else -1.0
	return dir_x