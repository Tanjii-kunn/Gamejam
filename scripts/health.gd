extends TextureProgressBar

@export var Player: player

func _physics_process(delta: float) -> void:
	value = Player.cchealth
	if value < 10:
		if $"../regent".is_stopped():
			$"../regent".start()
	elif value == 10:
		$"../regent".stop()
		


func _on_regent_timeout() -> void:
	value += Player.regenhealth
	print("ada")
