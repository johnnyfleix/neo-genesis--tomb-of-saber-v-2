class_name  HurtboxComponent
extends Area2D

@export var health: HealthComponent
@export var knockback: KnockbackComponent
@export var animation_component: AnimationComponent
@export var invulnerability_time: float = 0.5
@export var  invulnerability_timer: Timer

var is_invulnerable: bool = false

func receive_damage(damage: float, source_position: Vector2 = Vector2.ZERO, force: Vector2 = Vector2.ZERO, hitstop_duration: float = 0.0) -> void:
    #print("Hurtbox hit registered! Source: ", source_position) # <-- TEST 1
    if is_invulnerable:
        return

    if health:
        health.take_damage(damage)
        is_invulnerable = true
        if invulnerability_timer:
            invulnerability_timer.start(invulnerability_time)

    # Trigger flash using AnimationComponent
    if animation_component:
        #print("Hurtbox calling play_hit_flash()...")
        animation_component.play_hit_flash()

    else :
        #print("HurtboxComponent: animation_component slot is NULL in Inspector!")
        return


    if knockback and source_position != Vector2.ZERO:
        if hitstop_duration > 0.0:
                knockback.hitstop_duration = hitstop_duration
        knockback.apply_knockback(source_position, global_position, force)

func _on_timer_timeout() -> void:
    is_invulnerable = false