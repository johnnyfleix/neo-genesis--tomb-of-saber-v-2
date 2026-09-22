class_name HazardArea
extends Area2D

@export var damage: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_entered(area: Area2D) -> void:
	if area is HurtboxComponent:
		var hurtbox = area as HurtboxComponent

		# Apply Damage through HurtboxComponent
		hurtbox.receive_damage(damage)

		var targer_node = hurtbox.owner if hurtbox.owner else hurtbox.get_parent()
		var respawn_comp = targer_node.find_child("RespawnComponent", true, false) as RespawnComponent

		if respawn_comp and hurtbox.health and not hurtbox.health.is_dead:
			respawn_comp.respawn_at_checkpoint()