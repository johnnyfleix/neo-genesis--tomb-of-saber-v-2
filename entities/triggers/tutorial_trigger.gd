extends Area2D


@export var action_name: String
@export var action_text: String
@export var one_time_only: bool = true

var has_been_triggered: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().call_group("TutorialHint", "show_hint", action_name, action_text)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().call_group("TutorialHint", "hide_hint")
		if one_time_only:
			has_been_triggered = true
			queue_free()
