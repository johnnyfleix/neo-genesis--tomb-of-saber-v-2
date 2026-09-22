# Component providing advanced platformer jumping mechanics including coyote time, jump buffering, and variable jump height.
class_name AdvancedJumpComponent
extends Node

@export_subgroup("Timers")
# Timer used to buffer jump inputs pressed just before landing.
@export var jump_buffer_timer: Timer
# Timer allowing the player to jump briefly after stepping off a ledge.
@export var coyote_timer: Timer

@export_subgroup("Jump Settings")
# Initial vertical velocity applied when initiating a jump.
@export var jump_velocity: float

# Tracks whether the character is currently moving upwards in the air.
var is_going_up: bool = false
# Tracks whether an active jump is currently in progress.
var is_jumping: bool = false
# Stores the grounded state of the character from the previous physics frame.
var last_frame_on_floor: bool = false

# Checks if the character transitioned from airborne to grounded on the current frame.
func has_just_landed(body: CharacterBody2D) -> bool:
	return body.is_on_floor() and not last_frame_on_floor and is_jumping

# Evaluates whether the character is permitted to jump based on floor contact or active coyote time.
func is_allowed_to_jump(body: CharacterBody2D, want_to_jump: bool) -> bool:
	return want_to_jump and (body.is_on_floor() or not coyote_timer.is_stopped())

# Coordinates the full jump lifecycle, evaluating landing, coyote time, buffering, execution, and variable height.
func handle_jump(body: CharacterBody2D, want_to_jump: bool, jump_released: bool) -> void:
	if has_just_landed(body):
		is_jumping = false
	
	handle_coyote_time(body)
	handle_jump_buffer(body, want_to_jump)
	
	if is_allowed_to_jump(body, want_to_jump):
		jump(body)

	handle_variable_jump_height(body, jump_released)

	is_going_up = body.velocity.y < 0 and not body.is_on_floor()
	last_frame_on_floor = body.is_on_floor()

# Cuts vertical velocity to zero if the jump button is released early while ascending.
func handle_variable_jump_height(body: CharacterBody2D, jump_released: bool) -> void:
	if jump_released and is_going_up:
		body.velocity.y = 0

# Starts the buffer timer if jump is pressed mid-air, and triggers a jump if grounded while buffer is active.
func handle_jump_buffer(body: CharacterBody2D, want_to_jump: bool) -> void:
	if want_to_jump and not body.is_on_floor():
		jump_buffer_timer.start()
	
	if body.is_on_floor() and not jump_buffer_timer.is_stopped():
		jump(body)

# Checks if the character transitioned from grounded to airborne without jumping (stepping off a ledge).
func has_just_stepped_off_ledge(body: CharacterBody2D) -> bool:
	return not body.is_on_floor() and last_frame_on_floor and not is_jumping

# Initiates coyote time when stepping off a ledge and suspends gravity while coyote time is active.
func handle_coyote_time(body: CharacterBody2D) -> void:
	if has_just_stepped_off_ledge(body):
		coyote_timer.start()

	if not coyote_timer.is_stopped() and not is_jumping:
		body.velocity.y = 0

# Applies jump velocity, sets jumping state, and stops auxiliary timers.
func jump(body: CharacterBody2D) -> void:
	body.velocity.y = jump_velocity
	jump_buffer_timer.stop()
	is_jumping = true
	coyote_timer.stop()