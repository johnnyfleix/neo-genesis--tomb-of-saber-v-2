class_name GameOverHud
extends CanvasLayer

signal respawn_requested
signal exit_requested

@export var death_component: DeathComponent
@export var color_rect: ColorRect

var is_waiting_for_input: bool = false

func _ready() -> void:
    visible = false
    if color_rect:
        color_rect.color = Color(0, 0, 0, 1) # Semi-transparent black

    if death_component:
        death_component.entity_died.connect(_on_entity_died)


func _on_entity_died() -> void:
    visible = true
    is_waiting_for_input = true
    print("Game Over: Press 'Y' to Respawn or 'N' to Exit.")

func _unhandled_input(event: InputEvent) -> void:
    if not is_waiting_for_input:
        return
    
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_Y:
            _confirm_respawn()
        elif event.keycode == KEY_N:
            _confirm_exit()

func _confirm_respawn() -> void:
    is_waiting_for_input = false
    visible = false
    respawn_requested.emit()
    print("Respawn requested.")

func _confirm_exit() -> void:
    is_waiting_for_input = false
    print("Exit confirmed. Quitting game...")
    exit_requested.emit()
    get_tree().quit()