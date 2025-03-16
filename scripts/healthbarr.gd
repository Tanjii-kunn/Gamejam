extends TextureProgressBar

@onready var timer: Timer = $Timer

func _physics_process(delta: float) -> void:
	if value < 10:
		timer.start()

func _on_timer_timeout() -> void:
	print("jello")
