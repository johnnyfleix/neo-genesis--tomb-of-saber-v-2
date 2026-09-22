# Component responsible for applying gravitational acceleration to a character body.
class_name GravityComponent

extends Node

# Gravitational acceleration rate in pixels per second squared.
@export var gravity: float = 980

# Tracks whether the character is currently in a falling state (moving downwards in air).
var is_falling: bool = false

# Applies gravity to the body's vertical velocity if it is not grounded.
func handle_gravity(body: CharacterBody2D, delta: float) -> void:
	if not body.is_on_floor():
		body.velocity.y += gravity * delta
	
	is_falling = body.velocity.y > 0 and not body.is_on_floor()