# Main player character controller.
# Owns all component references and delegates execution to StateMachine.
# All per-state logic has been removed from this file; individual State scripts
# (IdleState, RunState, etc.) are responsible for calling into components.
class_name Player
extends CharacterBody2D

@export_subgroup("Components")
@export var death_component: DeathComponent
@export var gravity_component: GravityComponent
@export var input_component: InputComponent
@export var movement_component: MovementComponent
@export var jump_component: AdvancedJumpComponent
@export var animation_component: AnimationComponent
@export var knockback_component: KnockbackComponent
@export var health_component: HealthComponent
@export var respawn_component: RespawnComponent

@export_subgroup("Settings")
# Collision layer index used for one-way platform drop-through.
@export var drop_down_collision_layer: int = 5

@export_subgroup("FSM")
@export var state_machine: StateMachine

# Tracks the current horizontal facing direction of the player.
var facing_direction: float = 1.0

func _ready() -> void:
	if death_component:
		death_component.entity_died.connect(_on_player_died)
	else:
		push_error("Player: Missing DeathComponent!")

	# Auto-discover RespawnComponent if not explicitly assigned in Inspector
	if not respawn_component:
		respawn_component = find_child("RespawnComponent", true, false) as RespawnComponent

	if respawn_component:
		respawn_component.respawn_completed.connect(_on_respawn_completed)

	if state_machine:
		state_machine.init(self)
	else:
		push_error("Player: Missing StateMachine — assign it in the Inspector!")

func _physics_process(delta: float) -> void:
	# Capture floor state before move_and_slide() resolves it,
	# then pass it to post_physics_update for landing detection.
	var was_on_floor := is_on_floor()
	state_machine.physics_update(delta)
	move_and_slide()
	state_machine.post_physics_update(was_on_floor)

# Temporarily disables collision with one-way platforms to drop through them.
# Called by states that allow dropping (Idle, Run, Stop, Air).
func drop_down() -> void:
	set_collision_mask_value(drop_down_collision_layer, false)
	await get_tree().create_timer(0.4).timeout
	set_collision_mask_value(drop_down_collision_layer, true)

func _on_player_died() -> void:
	state_machine.transition_to(&"DeadState")

func _on_respawn_completed() -> void:
	print("Player respawn completed — transitioning StateMachine back to active state.")
	if state_machine:
		if is_on_floor():
			state_machine.transition_to(&"IdleState")
		else:
			state_machine.transition_to(&"AirState")

# Direct callback for RespawnComponent if called directly
func on_respawn() -> void:
	_on_respawn_completed()
