extends Control

@onready var label: Label = $TotalGemCount

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#GemWallet.gem_change.connect(update_gem)
	#update_gem(GemWallet.total_gems)
	pass



func update_gem(amount: int):
	label.text = str(amount)
