class_name MovementComponent
extends Node

# Movement speed in pixels per second.
@export var speed: float = 300.0

# Calculates and applies horizontal velocity based on input direction, then updates sprite orientation.
# Pass an optional override_speed (e.g. glide_speed) to use a different speed for specific states.
func handle_horizontal_movement(body: CharacterBody2D, direction: float, override_speed: float = -1.0) -> void:
	var move_speed := speed if override_speed < 0.0 else override_speed
	body.velocity.x = direction * move_speed
	flip_body(body)

func handle_stop_movement(body: CharacterBody2D, stop_pressed: bool) -> void:
	if stop_pressed:
		body.velocity.x = 0
		flip_body(body)

# Flips the character body horizontally based on the direction of horizontal velocity.
func flip_body(body: CharacterBody2D) -> void:
	if body.velocity.x > 0.0:
		body.scale.x = body.scale.y * 1.0
	if body.velocity.x < 0.0:
		body.scale.x = body.scale.y * -1.0