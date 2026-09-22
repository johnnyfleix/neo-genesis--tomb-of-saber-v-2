class_name DeathComponent
extends Node

@export var target: Node2D
@export var health: HealthComponent
@export var animation: AnimationComponent

@export_group("Death Behavior")

# Should target.queue_free() be called automatically after death?
@export var disable_and_queue_free: bool = false

# Delay in seconds before queue_free() is called
@export var cleanup_delay: float = 0.0

@export_group("Fx & Scenes")
# Packed scenes to instantiate on death (Cool fx & Stuff!)
@export var death_effect_scene: PackedScene

signal entity_died

func _ready() -> void:
    if health:
        health.died.connect(_on_death)
    else:
        push_error("DeathComponent: HealthComponent slot aint connected nga!")

func _on_death() -> void:
    print("DeathComponent: Entity has died!")

    # 1. Disable collision and physics processing on target
    _disable_target()

    # 2. Spawn death vfx (Assuming there's any!)
    _spawn_death_effect()

    # 3. Play death animation and wait for completion
    if animation:
        animation.handle_death_animation()
        await animation.death_animation_finished

    # 4. Emit signal so State machine or game managers can listen
    entity_died.emit()

    # 5. Cleanup
    _cleanup()

func _disable_target() -> void:
    if not target:
        push_error("DeathComponent: target is NULL!")
        return
    
    target.set_physics_process(false)
    target.set_process(false)

    for child in target.find_children("*", "CollisionShape2D"):
        if child is CollisionShape2D:
            child.set_deferred("disabled", true)

    
# Instantiates death fx scene at the target's global position
func _spawn_death_effect() -> void:
    if not death_effect_scene or not target:
        print("No death effect scene found... Lame + Boring!")
        return
    
    var effect_instance = death_effect_scene.instantiate()
    if effect_instance is Node2D:
        effect_instance.global_position = target.global_position
        target.get_tree().current_scene.add_child(effect_instance)
    else:
        push_error("DeathComponent: Death effect scene is not a Node2D!")

# Handle cleanup!
func _cleanup() -> void:
    if not disable_and_queue_free or not target:
        return
    
    if cleanup_delay > 0.0:
        await get_tree().create_timer(cleanup_delay).timeout
        target.queue_free()