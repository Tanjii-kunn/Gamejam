extends Control


func _on_play_pressed() -> void:
	await get_tree().create_timer(0.6).timeout
	get_tree().change_scene_to_file("res://scenes/intro.tscn")


func _on_options_pressed() -> void:
	pass
