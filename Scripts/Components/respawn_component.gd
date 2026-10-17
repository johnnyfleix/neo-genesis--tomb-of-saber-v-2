class_name RespawnComponent
extends Node

@export_group("Required Nodes")
@export var target: Node2D
@export var health: HealthComponent
@export var death_component: DeathComponent
@export var animation_component: AnimationComponent
@export var knockback_component: KnockbackComponent
@export var input_component: InputComponent
@export var game_over_hud: GameOverHud

@export_group("Float/Respawn Settings")
@export var respawn_delay: float = 0.1
## Speed at which the player floats back (pixels per second)
@export var float_speed: float = 600.0
## Minimum duration for floating, so short distances still feel smooth
@export var min_float_duration: float = 0.4
## Easing transition curve for the float movement
@export var float_trans_type: Tween.TransitionType = Tween.TRANS_SINE
@export var float_ease_type: Tween.EaseType = Tween.EASE_IN_OUT

@export_group("Float Visuals")
## Alpha opacity while floating back (0.5 = semi-transparent ghost)
@export var float_alpha: float = 0.5
## Name of the animation to play while floating back
@export var float_animation_name: String = "stock_fall"

# Starting position if no checkpoint has been hit yet
var spawn_position: Vector2 = Vector2.ZERO
var last_checkpoint_position: Vector2 = Vector2.ZERO

signal respawn_started
signal respawn_completed

func _ready() -> void:
	if target:
		spawn_position = target.global_position
		last_checkpoint_position = spawn_position

	if game_over_hud:
		game_over_hud.respawn_requested.connect(_on_full_death)
	elif death_component:
		death_component.entity_died.connect(_on_full_death)

# Updates the active checkpoint position
func set_checkpoint(new_checkpoint_position: Vector2) -> void:
	last_checkpoint_position = new_checkpoint_position
	print("Checkpoint set to: ", last_checkpoint_position)

# Respawns the player by smoothly floating back to the last active checkpoint
func respawn_at_checkpoint() -> void:
	_float_to_position(last_checkpoint_position, false)

# Respawns the player by floating back to the initial level spawn and resetting HP
func respawn_at_start() -> void:
	_disable_target_physics()
	respawn_started.emit()

	if respawn_delay > 0.0:
		await get_tree().create_timer(respawn_delay).timeout

	if health:
		health.reset_health() # Reset health to max duh

	if target:
		target.global_position = spawn_position

	# Reset active checkpoint back to start position
	last_checkpoint_position = spawn_position

	_enable_target_physics()
	respawn_completed.emit()

func float_to_position(destination: Vector2, is_full_reset: bool) -> void:
	if not target:
		return
	
	respawn_started.emit()
	_disable_target_physics()

	# 1. Play float animation & adjust sprite direction towards checkpoint
	if animation_component:
		animation_component.handle_float_animation(float_animation_name)
		var float_dir = sign(destination.x - target.global_position.x)
		
		if float_dir != 0:
			animation_component.handle_horizontal_flip(float_dir)

	# 2. Visual feedback: Make player semi-transparent while floating
	var original_modulate = target.modulate
	target.modulate.a = float_alpha

	# 3. Calculate dynamic duration based on distance
	var distance = target.global_position.distance_to(destination)
	var float_duration = max(distance / float_speed, min_float_duration)

	# 4. Create Tween to move target global position to destination
	var tween = create_tween().set_parallel(true)
	tween.tween_property(target, "global_position", destination, float_duration).set_trans(float_trans_type).set_ease(float_ease_type)

	# Wait until the floating tween finishes
	await tween.finished

	# 5. Handle logic resets after arrival
	if is_full_reset:
		if health:
			health.reset_health()
		last_checkpoint_position = spawn_position

	# 6. Restore transparency and re-enable collisions/controls
	target.modulate = original_modulate
	_enable_target_physics()

	respawn_completed.emit()

func _on_full_death() -> void:
	respawn_at_start()

## Core floating logic using Godot 4 Tweens
func _float_to_position(destination: Vector2, is_full_reset: bool) -> void:
	if not target:
		return

	respawn_started.emit()
	_disable_target_physics()

	# 1. Visual feedback: Make player semi-transparent while floating
	var original_modulate = target.modulate
	target.modulate.a = float_alpha

	# 2. Calculate dynamic duration based on distance so speed remains consistent
	var distance = target.global_position.distance_to(destination)
	var float_duration = max(distance / float_speed, min_float_duration)

	# 3. Create Tween to move target global position to destination
	var tween = create_tween().set_parallel(true)
	tween.tween_property(target, "global_position", destination, float_duration)\
		.set_trans(float_trans_type)\
		.set_ease(float_ease_type)

	# Wait until the floating tween finishes
	await tween.finished

	# 4. Handle logic resets after arrival
	if is_full_reset:
		if health:
			health.reset_health()
		last_checkpoint_position = spawn_position

	# 5. Restore transparency and re-enable collisions/controls
	target.modulate = original_modulate
	_enable_target_physics()

	respawn_completed.emit()

func _disable_target_physics() -> void:
	if target:
		target.set_physics_process(false)
		target.set_process(false)

		# Disable hitboxes & hurtboxes during float
		for child in target.find_children("*", "CollisionShape2D"):
			if child is CollisionShape2D:
				child.set_deferred("disabled", true)

func _enable_target_physics() -> void:
	if not target:
		return

	if target is CharacterBody2D:
		(target as CharacterBody2D).velocity = Vector2.ZERO

	if input_component and input_component.has_method("reset_input_state"):
		input_component.reset_input_state()

	if knockback_component and knockback_component.has_method("reset_knockback"):
		knockback_component.reset_knockback()

	target.set_physics_process(true)
	target.set_process(true)

	for child in target.find_children("*", "CollisionShape2D"):
		if child is CollisionShape2D:
			child.set_deferred("disabled", false)

	if animation_component:
		animation_component.reset_animation_state()

	if target.has_method("on_respawn"):
		target.on_respawn()