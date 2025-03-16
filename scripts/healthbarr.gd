extends TextureProgressBar

@onready var timer: Timer = $Timer

func _physics_process(delta: float) -> void:

	timer.wait_time = randf_range(0.8 , 2.1)

	if  value > 0:
		value -= 1
		if timer.is_stopped():
			timer.start()

func _on_timer_timeout() -> void:
	if value < 10:
		value += 1
