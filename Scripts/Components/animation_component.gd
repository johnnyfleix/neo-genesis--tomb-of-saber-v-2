class_name AnimationComponent
extends Node

signal death_animation_finished

@export_subgroup("Nodes")
@export var sprite: AnimatedSprite2D

@export_subgroup("Hit Flash")
@export var default_flash_duration: float = 0.2



var is_landing: bool = false
var is_dead: bool = false

func _ready() -> void:
	if sprite:
		sprite.animation_finished.connect(_on_animation_finished)

func _on_animation_finished() -> void:
	if sprite.animation == "stock_land":
		is_landing = false
	elif sprite.animation == "stock_death":
		death_animation_finished.emit()

func handle_death_animation() -> void:
	is_dead = true
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("stock_death"):
		sprite.play("stock_death")
		print("Playing Stock's blegh!")
	else:
		death_animation_finished.emit()
	

func play_hit_flash(duration: float = 0.0) -> void:
	if not sprite or not (sprite.material is ShaderMaterial):
		return
	
	var mat = sprite.material as ShaderMaterial
	var flash_time = duration if duration > 0.0 else default_flash_duration

	mat.set_shader_parameter("active", true)

	# ignore_time_scale = true ensures flash clears even if hitstop freezes the frame

	await get_tree().create_timer(flash_time, true, false, true).timeout
	
	mat.set_shader_parameter("active", false)


func handle_horizontal_flip(move_direction: float) -> void:
	if is_dead or move_direction == 0:
		return
	
	sprite.flip_h = move_direction < 0

func handle_move_animation(move_direction: float) -> void:
	if not is_dead and not is_landing and move_direction != 0:
		sprite.play("stock_crawl")

func handle_jump_animation(is_jumping: bool) -> void:
	if not is_dead and is_jumping:
		is_landing = false
		sprite.play("stock_jump")

func handle_stop_animation(is_stopping: bool) -> void:
	if not is_dead and not is_landing and is_stopping:
		sprite.play("stock_stop")

func handle_fall_animation(is_falling: bool) -> void:
	if not is_dead and is_falling:
		is_landing = false
		sprite.play("stock_fall")

func handle_land_animation(has_landed: bool) -> void:
	if not is_dead and has_landed:
		sprite.play("stock_land")
		is_landing = true

func reset_animation_state() -> void:
	is_dead = false
	is_landing = false
	
	if sprite:
		sprite.play("stock_fall") # My default