# Player is stationary on the ground with no directional intent.
# This is the default landing state and the game-start state.
# Exits to RunState on a fresh direction press, StopState when stop is held,
# AirState when the player leaves the floor, or KnockbackState on hit.
class_name IdleState
extends State

func enter() -> void:
	print("ENTERED IDLE STATE")
	player.velocity.x = 0.0
	# If we just landed, let the land animation finish before showing idle.
	if not player.animation_component.is_landing:
		player.animation_component.handle_stop_animation(true)

func exit() -> void:
	print("EXIT IDLE STATE")

func physics_update(delta: float) -> void:
	var input := player.input_component
	var want_jump   := input.get_jump_input()
	var jump_released := input.get_jump_input_released()
	var is_dropping := input.get_drop_input()

	player.gravity_component.handle_gravity(player, delta)
	player.jump_component.handle_jump(player, want_jump and not is_dropping, jump_released)

	if is_dropping:
		player.drop_down()

	# Ensure idle/stop animation plays once landing finishes
	player.animation_component.handle_stop_animation(true)

	# --- Transition priority order ---

	# Knockback always wins
	if player.knockback_component and player.knockback_component.is_knockback_active():
		state_machine.transition_to(&"KnockbackState")
		return

	# Stop key takes priority over run
	if input.stock_stop_input():
		state_machine.transition_to(&"StopState")
		return

	# Fresh direction press triggers a run
	if Input.is_action_just_pressed("move_right") or Input.is_action_just_pressed("move_left"):
		state_machine.transition_to(&"RunState")
		return

func post_physics_update(_was_on_floor: bool) -> void:
	# Transition to AirState if we are not on the floor after move_and_slide resolves
	if not player.is_on_floor():
		state_machine.transition_to(&"AirState")
