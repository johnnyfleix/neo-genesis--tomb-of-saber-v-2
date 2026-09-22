# Component responsible for polling and encapsulating player input actions.
class_name InputComponent

extends Node

# Stores the cached horizontal movement axis value (-1.0 to 1.0).
var input_horizontal: float = 0.0
# Stores the cached stock horizontal movement value (-1.0 or 1.0).
var stock_horizontal: float = 0.0

# Called every frame to poll continuous and discrete input actions.
func _process(_delta: float) -> void:
	get_horizontal_input()
	get_stock_move_input()
	get_jump_input()

# Polls the horizontal movement axis between left and right actions.
func get_horizontal_input() -> float:
	input_horizontal = Input.get_axis("move_left", "move_right")
	return input_horizontal

# Checks if the jump action was pressed during the current frame.
func get_jump_input() -> bool:
	return Input.is_action_just_pressed("jump")

# Checks if the jump action was released during the current frame.
func get_jump_input_released() -> bool:
	return Input.is_action_just_released("jump")

# Checks if the melee attack action was pressed during the current frame.
func get_attack_input() -> bool:
	return Input.is_action_just_pressed("attack")

# Checks if the player is pressing down and jump simultaneously to drop through platforms.
func get_drop_input() -> bool:
	return Input.is_action_pressed("down") and Input.is_action_just_pressed("jump")

# Checks if the shoot action is currently being held down.
func get_shoot_input() -> bool:
	return Input.is_action_pressed("shoot")

func get_stock_move_input() -> float:
	if Input.is_action_just_pressed("move_right"):
		stock_horizontal = 1.0
	elif Input.is_action_just_pressed("move_left"):
		stock_horizontal = -1.0
	
	return stock_horizontal

func stock_stop_input() -> bool:
	return Input.is_action_pressed("stop")

func reset_input_state() -> void:
	input_horizontal = 0.0
	stock_horizontal = 0.0