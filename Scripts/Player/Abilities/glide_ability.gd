class_name GlideAbility
extends AbilityComponent

signal glide_started
signal glide_stopped

@export_group("Glide Physics")
## Maximum downward speed while gliding (caps velocity.y)
@export var max_fall_speed: float = 120.0
## Optional: gravity multiplier while gliding (e.g. 0.2 for 20% gravity)
@export var gravity_multiplier: float = 0.25
## Horizontal movement speed while gliding in pixels per second
@export var glide_speed: float = 180.0

var is_gliding: bool = false

## Starts gliding if unlocked and airborne
func start_glide(user: Player) -> bool:
	if not super.can_use():
		return false

	is_gliding = true
	glide_started.emit()
	ability_activated.emit(data.ability_name)
	return true

## Stops gliding (called when button released or player lands)
func stop_glide() -> void:
	if not is_gliding:
		return
	
	is_gliding = false
	glide_stopped.emit()

## Applies modified falling physics to the player while gliding
func apply_glide_gravity(user: Player, delta: float) -> void:
	if not is_gliding:
		return

	# Apply reduced gravity from player's GravityComponent
	var base_gravity = user.gravity_component.gravity if user.gravity_component else 980.0
	user.velocity.y += (base_gravity * gravity_multiplier) * delta

	# Clamp vertical velocity so the player floats down softly
	if user.velocity.y > max_fall_speed:
		user.velocity.y = max_fall_speed