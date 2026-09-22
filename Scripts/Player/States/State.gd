# Abstract base class for all player states.
# Each concrete state extends this and overrides the virtual methods it cares about.
# References to `player` and `state_machine` are injected by StateMachine.init().
class_name State
extends Node

## The owning player. Injected once by StateMachine.init().
var player: Player
## Back-reference to the machine so states can call transition_to().
var state_machine: StateMachine

# Called by StateMachine.init() once during _ready.
func init(player_ref: Player, machine: StateMachine) -> void:
	player = player_ref
	state_machine = machine

## Called when this state becomes the active state.
func enter() -> void:
	pass

## Called when this state is exited and another is activated.
func exit() -> void:
	pass

## Called every physics tick, BEFORE move_and_slide().
## Use this to set velocity and queue transitions.
func physics_update(_delta: float) -> void:
	pass

## Called every physics tick, AFTER move_and_slide().
## Use this for transitions that depend on the resolved floor state
## (e.g., landing detection: was_on_floor → is_on_floor()).
func post_physics_update(_was_on_floor: bool) -> void:
	pass

