class_name HealthComponent
extends Node

@export var max_hp: float = 5.0
var current_hp: float = 5.0: set = set_current_hp

var is_dead: bool = false

signal health_changed(current: float, max: float)
signal max_health_changed(new_max: float)
signal died
signal hurt(amount: float)

func _ready() -> void:
    current_hp = max_hp
    health_changed.emit(current_hp, max_hp)


func set_current_hp(value: float) -> void:
    var new_hp = clamp(value, 0.0, max_hp)
    
    if is_equal_approx(new_hp, current_hp):
        return # no change → no need to emit anything
    
    var old_hp = current_hp
    current_hp = new_hp
    
    # How much damage was actually taken (useful for effects, UI shake, etc)
    var damage_taken = old_hp - current_hp
    if damage_taken > 0:
        hurt.emit(damage_taken)
        
    health_changed.emit(current_hp, max_hp)
    
    if current_hp <= 0:
        if not is_dead:
            is_dead = true
            died.emit()


func take_damage(amount: float) -> void:
    if amount <= 0:
        return
    current_hp -= amount # setter will handle clamping + signals

func heal(amount: float) -> void:
    if amount <= 0:
        return
    current_hp += amount # setter will handle clamping + signals


func upgrade_hp(amount: float) -> void:
    if amount <= 0:
        return
        
    max_hp += amount
    current_hp = max_hp # fully heal on max hp upgrade
    
    max_health_changed.emit(max_hp)

func reset_health() -> void:
    current_hp = max_hp
    is_dead = false
    health_changed.emit(current_hp, max_hp)

func kill() -> void:
    if is_dead:
        return
    
    current_hp = 0

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_focus_next"):
        reset_health()