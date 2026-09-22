# Active while the KnockbackComponent is applying a velocity impulse to the player.
# Player input is disabled; only knockback velocity and gravity are applied.
# Hit-flash and camera shake are already handled by HurtboxComponent / KnockbackComponent.
#
# Exits to IdleState when knockback decays and the player is grounded,
# or to AirState when knockback decays while the player is airborne.
class_name KnockbackState
extends State

func enter() -> void:
	print("ENTERED KNOCKBACK STATE")

func exit() -> void:
	print("EXIT KNOCKBACK STATE")
	# Clean up residual knockback impulse so force cannot leak into subsequent states
	if player.knockback_component:
		player.knockback_component.reset_knockback()

func physics_update(delta: float) -> void:
	var kb := player.knockback_component

	# Overwrite velocity with active knockback impulse
	player.velocity.x = kb.knockback_velocity.x
	if kb.knockback_velocity.y < 0.0:
		# Only override y when the impulse is upward (initial hit launch)
		player.velocity.y = kb.knockback_velocity.y

	# Gravity still accumulates during knockback
	player.gravity_component.handle_gravity(player, delta)

func post_physics_update(_was_on_floor: bool) -> void:
	# Once knockback has fully decayed, return to the appropriate state
	if not player.knockback_component.is_knockback_active():
		if player.is_on_floor():
			state_machine.transition_to(&"IdleState")
		else:
			state_machine.transition_to(&"AirState")
