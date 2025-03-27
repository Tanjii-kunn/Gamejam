extends Control




func _on_play_pressed() -> void:
	await get_tree().create_timer(0.6).timeout
	get_tree().change_scene_to_file("res://scenes/intro.tscn")

func _on_h_slider_value_changed(value: float) -> void:
	var bus := "Master"
	var normalized_value = value / 10.0  # Convert 0-10 range to 0-1
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), linear_to_db(normalized_value))
