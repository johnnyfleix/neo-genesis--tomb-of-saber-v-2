# Unified airborne state covering ascending (jump), descending (fall),
# and the landing moment. All air sub-phases are expressed via animation;
# no additional state nodes are needed.
#
# Landing is detected in post_physics_update() AFTER move_and_slide() resolves
# the floor contact, which is the correct place to read is_on_floor().
# On land: triggers the land animation, then transitions to IdleState.
class_name AirState
extends State

func enter() -> void:
	print("ENTER AIR STATE")
	_update_air_animation()

func exit() -> void:
	print("EXIT AIR STATE")

func physics_update(delta: float) -> void:
	var input         := player.input_component
	var move_input    := input.get_stock_move_input()
	var want_jump     := input.get_jump_input()
	var jump_released := input.get_jump_input_released()
	var is_dropping   := input.get_drop_input()

	# Allow aerial horizontal influence
	player.movement_component.handle_horizontal_movement(player, move_input)
	player.gravity_component.handle_gravity(player, delta)
	# Handles variable height, coyote time, and jump buffering
	player.jump_component.handle_jump(player, want_jump and not is_dropping, jump_released)

	if is_dropping:
		player.drop_down()

	_update_air_animation()

	# Knockback overrides aerial movement
	if player.knockback_component and player.knockback_component.is_knockback_active():
		state_machine.transition_to(&"KnockbackState")
		return

func post_physics_update(_was_on_floor: bool) -> void:
	# Detect landing: if grounded after move_and_slide resolves
	if player.is_on_floor():
		player.animation_component.handle_land_animation(true)
		var input := player.input_component
		if input.stock_stop_input():
			state_machine.transition_to(&"StopState")
		elif input.stock_horizontal != 0.0:
			state_machine.transition_to(&"RunState")
		else:
			state_machine.transition_to(&"IdleState")

# Plays jump or fall animation based on current vertical velocity direction.
func _update_air_animation() -> void:
	if player.velocity.y < 0.0:
		player.animation_component.handle_jump_animation(true)
	else:
		player.animation_component.handle_fall_animation(true)
