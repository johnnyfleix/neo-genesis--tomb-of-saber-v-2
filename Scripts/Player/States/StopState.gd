# Player is holding the stop input. Horizontal movement is locked to zero.
# Jumping and dropping through platforms are still allowed.
# Knockback can still interrupt this state.
# Exits when stop is released: → RunState if a direction is cached, else → IdleState.
# Exits to AirState if the player leaves the floor (via jump or fall).
class_name StopState
extends State

func enter() -> void:
	print("ENTERED STOP STATE")
	player.velocity.x = 0.0
	player.animation_component.handle_stop_animation(true)

func exit() -> void:
	print("EXIT STOP STATE")

func physics_update(delta: float) -> void:
	var input         := player.input_component
	var want_jump     := input.get_jump_input()
	var jump_released := input.get_jump_input_released()
	var is_dropping   := input.get_drop_input()

	# Lock horizontal movement; flip_body is a no-op when velocity.x == 0
	player.velocity.x = 0.0

	player.gravity_component.handle_gravity(player, delta)
	player.jump_component.handle_jump(player, want_jump and not is_dropping, jump_released)

	if is_dropping:
		player.drop_down()

	# Ensure stop animation plays once landing finishes
	player.animation_component.handle_stop_animation(true)

	# --- Transition priority order ---

	# Knockback cannot be suppressed by holding stop
	if player.knockback_component and player.knockback_component.is_knockback_active():
		state_machine.transition_to(&"KnockbackState")
		return

	# Exit stop when the stop key is released
	if not input.stock_stop_input():
		if input.stock_horizontal != 0.0:
			state_machine.transition_to(&"RunState")
		else:
			state_machine.transition_to(&"IdleState")
		return

func post_physics_update(_was_on_floor: bool) -> void:
	# Left the floor while stopping (e.g. jumped while stop is held)
	if not player.is_on_floor():
		state_machine.transition_to(&"AirState")
