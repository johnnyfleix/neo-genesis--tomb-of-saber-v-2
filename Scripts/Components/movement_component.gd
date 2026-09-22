# Component responsible for applying horizontal movement and managing character facing orientation.
class_name MovementComponent
extends Node

# Movement speed in pixels per second.
@export var speed: float = 300.0

# Calculates and applies horizontal velocity based on input direction, then updates sprite orientation.
func handle_horizontal_movement(body: CharacterBody2D, direction: float) -> void:
	body.velocity.x = direction * speed
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
