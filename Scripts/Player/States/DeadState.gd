# State entered when the player dies.
# DeathComponent (listening to HealthComponent.died) handles:
#   - disabling collision shapes
#   - disabling set_physics_process / set_process on the Player
#   - playing the death animation
#   - spawning death VFX
# When exiting (on respawn), exit() ensures animation state is reset
# so normal animations can play again.
class_name DeadState
extends State

func enter() -> void:
	print("ENTERED DEAD STATE")
	player.velocity = Vector2.ZERO

func exit() -> void:
	print("EXIT DEAD STATE")
	# Clean up death state: reset animation component flags so animations can play
	if player.animation_component:
		player.animation_component.reset_animation_state()

func physics_update(_delta: float) -> void:
	pass  # No-op while dead

func post_physics_update(_was_on_floor: bool) -> void:
	pass  # No-op while dead
