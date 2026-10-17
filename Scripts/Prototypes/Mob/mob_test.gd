#Mob enemy test script
extends CharacterBody2D

@export_subgroup("Components")
@export var death_component: DeathComponent
@export var gravity_component: GravityComponent
@export var movement_component: MovementComponent
@export var jump_component: JumpComponent
@export var knockback_component: KnockbackComponent
@export var health_component: HealthComponent
@export var target: Player
@export var chase_area: Area2D
@export var player_detector: RayCast2D
@export var ground_detecr: RayCast2D
@export var hazard_detector: RayCast2D

# State variables
var is_player_in_chase_area: bool = false

func _physics_process(delta: float) -> void:
	controller(delta)
	move_and_slide()

func controller(delta: float) -> void:
	var health: HealthComponent = health_component
	var death: DeathComponent = death_component
	var gravity: GravityComponent = gravity_component
	var movement: MovementComponent = movement_component
	var jump: JumpComponent = jump_component
	var player: Player = target
	gravity.handle_gravity(self, delta)

	chase_player(player, movement)


func _on_chase_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Stock"):
		is_player_in_chase_area = true

func _on_chase_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Stock"):
		is_player_in_chase_area = false

func chase_player(player: Player, movement: MovementComponent) -> void:
	if is_player_in_chase_area:
		var direction: float = sign(player.global_position.x - global_position.x)

		movement.handle_horizontal_movement(self, direction)

	elif not ground_detecr.is_colliding():
		movement_component.handle_horizontal_movement(self, 0)

	elif hazard_detector.is_colliding():
		movement_component.handle_horizontal_movement(self, 0)
	
	else :
		movement.handle_horizontal_movement(self, 0.0)


