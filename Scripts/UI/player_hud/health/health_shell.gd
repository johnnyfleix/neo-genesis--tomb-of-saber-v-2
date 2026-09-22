extends Node2D
class_name HealthShell

@onready var sprite: Sprite2D = $ShellSprite
@onready var anim_player: AnimationPlayer = $AnimationPlayer

const FULL_TEXTURE = preload("res://ui/PNGs/health_state/health_full.png")
const CRACKED_TEXTURE = preload("res://ui/PNGs/health_state/health_cracked.png")
const BLANK_TEXTURE = preload("res://ui/PNGs/health_state/health_blank.png")

enum ShellState {
	FULL,
	CRACKED,
	BLANK
}

var current_state: ShellState = ShellState.FULL
var _initialized: bool = false

func _ready() -> void:
	# Defer so the AnimationPlayer's library is fully loaded before playing
	call_deferred("_deferred_init")

func _deferred_init() -> void:
	_apply_state(current_state)
	_initialized = true


func set_state(new_state: ShellState) -> void:
	if _initialized and new_state == current_state:
		return
	current_state = new_state
	_apply_state(new_state)


func _apply_state(state: ShellState) -> void:
	match state:
		ShellState.FULL:
			sprite.texture = FULL_TEXTURE
			anim_player.play("full_idle")
#			print("HP Full")

		ShellState.CRACKED:
			sprite.texture = CRACKED_TEXTURE
			anim_player.play("cracked_shake")
#			print("HP Cracked")

		ShellState.BLANK:
			sprite.texture = BLANK_TEXTURE
			anim_player.play("break_transition")
#			await anim_player.animation_finished
#			anim_player.stop()
#			print("HP Blank")