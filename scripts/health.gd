extends TextureProgressBar

@export var Player: player

func _physics_process(_delta: float) -> void:
	value = Player.cchealth
