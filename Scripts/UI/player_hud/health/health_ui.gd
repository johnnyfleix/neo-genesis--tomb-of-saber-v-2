extends CanvasLayer

@onready var container: Node2D = $Container
@onready var health_shell: PackedScene = preload("res://ui/Scenes/health_shell.tscn")
@export var health_manager: HealthComponent

const HEART_ROW_SIZE: int = 12
const HEART_OFFSET: int = 74

func _ready():
	instancing_health_icons()
	health_manager.health_changed.connect(_on_health_changed)
	health_manager.max_health_changed.connect(_on_max_health_changed)
	#print("Signal connected: ", health_manager.health_changed.is_connected(_on_health_changed))

func instancing_health_icons():
	for child in container.get_children():
		child.free()
	for i in health_manager.max_hp:
		var new_heart = health_shell.instantiate()
		container.add_child(new_heart)
	update_health_icons()
	update_shell_states(health_manager.current_hp)

func update_health_icons():
	for health in container.get_children():
		var index = health.get_index()
		var x = (index % HEART_ROW_SIZE) * HEART_OFFSET
		var y = (index / HEART_ROW_SIZE) * HEART_OFFSET
		health.position = Vector2(x, y)

func update_shell_states(current_hp: float):
	var shells = container.get_children()
	for i in shells.size():
		var shell = shells[i] as HealthShell
		if current_hp >= i + 1.0:
			shell.set_state(HealthShell.ShellState.FULL)
		elif current_hp >= i + 0.5:
			shell.set_state(HealthShell.ShellState.CRACKED)
		else:
			shell.set_state(HealthShell.ShellState.BLANK)

func _on_health_changed(current: float, _max: float):
	#print("UI received health change: ", current)
	update_shell_states(current)

func _on_max_health_changed(_new_max: float):
	instancing_health_icons()
