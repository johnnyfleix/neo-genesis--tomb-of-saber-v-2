class_name CameraShakeComponent
extends Node

@export var camera: Camera2D
@export var max_shake_x: float = 10.0
@export var max_shake_y: float = 10.0
@export var shake_fade: float = 10.0

var _shake_strength_x: float = 0.0
var _shake_strength_y: float = 0.0
var _shake_timer: float = 0.0
var _shake_duration: float = 0.0

func trigger_shake(x_strength: float = max_shake_x, y_strength: float = max_shake_y, duration: float = 0.3) -> void:
	_shake_strength_x = x_strength
	_shake_strength_y = y_strength
	_shake_duration = duration
	_shake_timer = duration

func _process(_delta: float) -> void:
	var real_delta = get_process_delta_time()
	camera_shake(real_delta)

func camera_shake(delta: float) -> void:
	if not camera:
		return

	if _shake_timer > 0.0:
		_shake_timer -= delta

		var t = clamp(_shake_timer / _shake_duration, 0.0, 1.0)
		var current_x = lerp(0.0, _shake_strength_x, t)
		var current_y = lerp(0.0, _shake_strength_y, t)

		camera.offset = Vector2(
			randf_range(-current_x, current_x),
			randf_range(-current_y, current_y)
		)
	else:
		camera.offset = Vector2.ZERO
