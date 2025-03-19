extends TextureProgressBar

@export var Player: player

func _physics_process(delta: float) -> void:
	value = Player.cchealth
