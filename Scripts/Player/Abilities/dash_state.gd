class_name DashState
extends State

var dash_ability: DashAbility

func enter() -> void:
	print("ENTERED DASH STATE")

	if not player.ability_manager:
		push_error("DashState: No AbilityManagerComponent found on Player!")
		_return_to_default_state()
		return

	# Fetch the dash ability dynamically from the AbilityManager's dictionary
	if player.ability_manager.abilities.has("dash"):
		dash_ability = player.ability_manager.abilities["dash"] as DashAbility

	# Attempt to execute the dash
	var dash_executed := player.ability_manager.trigger_ability("dash")

	# If ability failed (cooldown/locked/missing), return immediately
	if not dash_executed:
		_return_to_default_state()
		return

	# Connect signal dynamically when dash successfully begins
	if dash_ability and not dash_ability.dash_ended.is_connected(_on_dash_ended):
		dash_ability.dash_ended.connect(_on_dash_ended, CONNECT_ONE_SHOT)

func exit() -> void:
	print("EXIT DASH STATE")

func physics_update(delta: float) -> void:
	# 1. Knockback priority override
	if player.knockback_component and player.knockback_component.is_knockback_active():
		state_machine.transition_to(&"KnockbackState")
		return

	# 2. Gravity continues during dash
	player.gravity_component.handle_gravity(player, delta)

	# 3. Maintain character facing orientation matching movement
	if player.velocity.x != 0.0:
		player.movement_component.flip_body(player)

func post_physics_update(_was_on_floor: bool) -> void:
	if not dash_ability or not dash_ability.is_dashing:
		_return_to_default_state()

func _on_dash_ended() -> void:
	if state_machine.current_state == self:
		_return_to_default_state()

func _return_to_default_state() -> void:
	if not player.is_on_floor():
		state_machine.transition_to(&"AirState")
		return

	var input := player.input_component
	if input and input.stock_stop_input():
		state_machine.transition_to(&"StopState")
	elif input and input.stock_horizontal != 0.0:
		state_machine.transition_to(&"RunState")
	else:
		state_machine.transition_to(&"IdleState")