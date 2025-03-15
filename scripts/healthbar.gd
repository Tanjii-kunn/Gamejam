extends TextureProgressBar

func _process(delta: float) -> void:
	if value < 10:
		print("low")
		$regentimer.start()
	elif value == 10:
		$regentimer.stop()
		print("high")

func _on_regentimer_timeout() -> void:
	value += 1
