extends CanvasLayer

func _ready() -> void:
	await get_tree().create_timer(3).timeout
	if Lvls.l1 == true:
		get_tree().change_scene_to_file("res://scenes/lvl2.tscn")
	elif Lvls.l2 == true:
		pass
	elif Lvls.l3 == true:
		pass
