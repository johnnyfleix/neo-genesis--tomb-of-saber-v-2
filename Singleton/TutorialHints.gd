extends Control

@onready var key_label: Label = $HBoxContainer/KeyPanel/KeyLabel
@onready var action_label: Label = $HBoxContainer/KeyPanel/ActionLabel

var tween: Tween

func _ready():
	#visible = false
	modulate.a = 0.0

func show_hint(action_name: String, action_text: String = "to Jump"):
	var events = InputMap.action_get_events(action_name)
	var key_text = "?"
	
	if not events.is_empty():
		var event = events[0]
		if event is InputEventKey:
			# NEW: Use this instead of as_text() to avoid the "- Physical" text
			key_text = event.as_text_physical_keycode()
			# Fallback if it's still weird
			if key_text.is_empty() or key_text == "?":
				key_text = OS.get_keycode_string(event.physical_keycode)
	
	key_label.text = key_text
	action_label.text = " " + action_text

	if tween and tween.is_running():
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self , "modulate:a", 1.0, 0.5)
	#visible = true

func hide_hint():
	if tween and tween.is_running():
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(self , "modulate:a", 0.0, 1.0)
	#visible = false
