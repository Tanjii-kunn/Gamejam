extends TextureProgressBar

@export var Player: player

func _physics_process(delta: float) -> void:
	value = Player.cchealth
	if value < 10:
		if $"../health/regent".is_stopped():
			$"../health/regent".start()
	elif value == 10:
		$"../health/regent".stop()

func _on_regent_timeout() -> void:
	# Increase player's health and update UI
	Player.cchealth = min(Player.cchealth + Player.regenhealth, 10)
	value = Player.cchealth  # Update UI
	print("Health regenerated!")
