# Player is moving horizontally on the ground.
# Uses stock-style movement: velocity is driven by the last-pressed direction
# cached in InputComponent.stock_horizontal.
# Exits to StopState on stop input, AirState when leaving the floor,
# or KnockbackState on hit.
class_name RunState
extends State

func enter() -> void:
	print("ENTERED RUN STATE")
	var move_input := player.input_component.get_stock_move_input()
	player.animation_component.handle_move_animation(move_input)

func exit() -> void:
	print("EXIT RUN STATE")

func physics_update(delta: float) -> void:
	var input        := player.input_component
	var move_input   := input.get_stock_move_input()
	var want_jump    := input.get_jump_input()
	var jump_released := input.get_jump_input_released()
	var is_dropping  := input.get_drop_input()

	# Apply horizontal movement (also calls flip_body internally)
	player.movement_component.handle_horizontal_movement(player, move_input)
	player.gravity_component.handle_gravity(player, delta)
	player.jump_component.handle_jump(player, want_jump and not is_dropping, jump_released)

	if is_dropping:
		player.drop_down()

	# Keep crawl animation current
	player.animation_component.handle_move_animation(move_input)

	# --- Transition priority order ---

	if player.knockback_component and player.knockback_component.is_knockback_active():
		state_machine.transition_to(&"KnockbackState")
		return

	if input.stock_stop_input():
		state_machine.transition_to(&"StopState")
		return

func post_physics_update(_was_on_floor: bool) -> void:
	# Left the floor (jumped or stepped off a ledge)
	if not player.is_on_floor():
		state_machine.transition_to(&"AirState")
