# Component responsible for handling basic jumping mechanics for a character body.
class_name JumpComponent
extends Node

@export_subgroup("Settings")
# Initial vertical velocity applied when jumping (typically a negative value in 2D coordinates).
@export var jump_height: float

# Tracks whether the character is currently in an active jump ascending state.
var is_jumping: bool = false

# Evaluates jump input and floor state to apply vertical jump velocity.
func handle_jump(body: CharacterBody2D, want_to_jump: bool) -> void:
	if want_to_jump and body.is_on_floor():
		body.velocity.y = jump_height

	is_jumping = body.velocity.y < 0 and not body.is_on_floor()