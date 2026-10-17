class_name GlideState
extends State

var glide_ability: GlideAbility

func enter() -> void:
	print("ENTERED GLIDE STATE")
	
	if player.ability_manager and player.ability_manager.abilities.has("glide"):
		glide_ability = player.ability_manager.abilities["glide"] as GlideAbility

	if not glide_ability or not glide_ability.start_glide(player):
		# If locked or missing, immediately return to AirState
		state_machine.transition_to(&"AirState")

func exit() -> void:
	print("EXIT GLIDE STATE")
	if glide_ability:
		glide_ability.stop_glide()

# Inside GlideState.gd
func physics_update(delta: float) -> void:
	var input := player.input_component
	var move_input := input.get_stock_move_input()
	var is_holding_float := input.float_input()

	# 1. Knockback priority override
	if player.knockback_component and player.knockback_component.is_knockback_active():
		state_machine.transition_to(&"KnockbackState")
		return

	# 2. Exit glide if button released or jump pressed
	if not is_holding_float or input.get_jump_input():
		state_machine.transition_to(&"AirState")
		return

	# 3. Handle horizontal movement with custom glide speed override
	var speed_override := glide_ability.glide_speed if glide_ability else -1.0
	player.movement_component.handle_horizontal_movement(player, move_input, speed_override)

	# 4. Apply glide physics (reduced gravity & fall speed limit)
	if glide_ability:
		glide_ability.apply_glide_gravity(player, delta)

		
func post_physics_update(_was_on_floor: bool) -> void:
	# Landed on ground
	if player.is_on_floor():
		player.animation_component.handle_land_animation(true)
		state_machine.transition_to(&"IdleState")
