# Manages the active player state and handles transitions between states.
# Sits as a direct child node of the Player scene.
# Call init(player) from Player._ready() to wire everything up.
class_name StateMachine
extends Node

## Set this to the starting State node in the Inspector.
@export var initial_state: State

var current_state: State
## Lookup table: node name (StringName) → State instance.
var states: Dictionary = {}

## Called by Player._ready(). Injects player reference into all child states
## and activates the initial state.
func init(player: Player) -> void:
	for child in get_children():
		if child is State:
			child.init(player, self)
			states[child.name] = child

	if not initial_state:
		push_error("StateMachine: No initial_state assigned in Inspector!")
		return

	current_state = initial_state
	current_state.enter()

## Exits the current state and enters the named state.
## state_name must exactly match the node name (e.g. &"IdleState").
func transition_to(state_name: StringName) -> void:
	if not states.has(state_name):
		push_error("StateMachine: Unknown state requested: " + str(state_name))
		return

	# Guard: avoid re-entering the same state
	if current_state == states[state_name]:
		return

	if current_state:
		current_state.exit()

	current_state = states[state_name]
	current_state.enter()

## Forwarded from Player._physics_process(), runs BEFORE move_and_slide().
func physics_update(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

## Forwarded from Player._physics_process(), runs AFTER move_and_slide().
## Passes the pre-slide floor state for landing detection.
func post_physics_update(was_on_floor: bool) -> void:
	if current_state:
		current_state.post_physics_update(was_on_floor)

## Resets the state machine back to its initial state.
## Useful for respawning or resetting character state.
func reset() -> void:
	if not initial_state:
		return
	transition_to(initial_state.name)

