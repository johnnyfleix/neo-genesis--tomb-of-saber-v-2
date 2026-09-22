class_name KnockbackComponent
extends Node

@export var default_force: Vector2 = Vector2(300.0, -150.0)

## Friction/damping rate for decaying knockback back to 0.
@export var knockback_damping: float = 12.0

@export_group("Hitstop Settings")
# Enable freeze frame when taking hits!
@export var use_hitsop: bool = true
# How long time stays frozen/slowed.
@export var hitstop_duration: float = 0.08
#Time scale during hitstop note fpr future (0.0 = tot. pause, 0.0 = micro-slomo)
@export var hitstop_time_scale: float = 0.0

@export_group("Screen Shake Settings")
@export var camera_shake_component: CameraShakeComponent
@export var shake_force: Vector2 = Vector2(10.0, 10.0)
@export var shake_duration: float = 0.2

var knockback_velocity: Vector2 = Vector2.ZERO

## Returns true if knockback is actively influencing movement.
func is_knockback_active() -> bool:
    return knockback_velocity.length_squared() > 10.0

func _physics_process(delta: float) -> void:
    if is_knockback_active():
        # Smoothly decay knockback velocity to zero
        knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, knockback_damping * delta)    
    else :
        knockback_velocity = Vector2.ZERO

func apply_knockback(source_position: Vector2, target_position: Vector2, custom_force: Vector2 = Vector2.ZERO) -> void:
    #print("Applied Knockback Velocity: ", knockback_velocity) # <-- TEST 2
    var force_to_apply = custom_force if custom_force != Vector2.ZERO else default_force
    var direction = sign(target_position.x - source_position.x)

    if direction == 0:
        direction = 1.0 #default right if properly aligned

    knockback_velocity = Vector2(direction * force_to_apply.x, force_to_apply.y)

    # Trigger Camera Shake Component
    if camera_shake_component:
        camera_shake_component.trigger_shake(shake_force.x, shake_force.y, shake_duration)

    # Trigger Hitstop
    if use_hitsop and hitstop_duration > 0.0:
        trigger_hitstop(hitstop_duration, hitstop_time_scale)


# Hitstop function
func trigger_hitstop(duration: float, scale: float = 0.0) -> void:
    Engine.time_scale = scale
    # process_always = true to ensure timer ticks even if time_scale is 0
    # process_in_physics = false uses real system time
    await get_tree().create_timer(duration, true, false, true).timeout
    Engine.time_scale = 1.0

func reset_knockback() -> void:
    knockback_velocity = Vector2.ZERO