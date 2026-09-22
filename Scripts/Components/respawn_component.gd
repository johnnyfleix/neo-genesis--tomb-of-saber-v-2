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

@export_group("Respawn Settings")
@export var respawn_delay: float = 0.5

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

# Respawns the player at the last active checkpoint (used for spikes / hazard drops)
func respawn_at_checkpoint() -> void:
    respawn_started.emit()

    _disable_target_physics()

    if respawn_delay > 0.0:
        await get_tree().create_timer(respawn_delay).timeout

    if target:
        target.global_position = last_checkpoint_position
        print("Respawning at checkpoint: ", last_checkpoint_position)

    _enable_target_physics()
    respawn_completed.emit()

# Respawns the player at the initial level spawn after HP reaches zero
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

func _on_full_death() -> void:
    # Full death triggers reset to initial start position
    respawn_at_start()

func _disable_target_physics() -> void:
    if target:
        target.set_physics_process(false)
        target.set_process(false)

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
            child.disabled = false

    if animation_component:
        animation_component.reset_animation_state()

    if target.has_method("on_respawn"):
        target.on_respawn()