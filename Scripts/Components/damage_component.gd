class_name DamageComponent
extends Area2D

@export var damage: float
@export var cooldown: float = 0.5
@export var damage_cooldown: Timer
@export var knockback_force: Vector2 = Vector2.ZERO # Allows per-attack custom force override

@export_group("Custom Hitstop")
# Set > 0 to override the target's default hitstop duration.
@export var custom_hitstop_duration: float = 0.0

var can_damage: bool = true

func _on_area_entered(area: Area2D) -> void:
    if not can_damage:
        return

    if area.has_method("receive_damage"):
        area.receive_damage(damage, global_position, knockback_force, custom_hitstop_duration)
        can_damage = false
        if damage_cooldown:
            damage_cooldown.start(cooldown)

func _on_damage_cooldown_timeout() -> void:
    can_damage = true