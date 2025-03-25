extends CanvasLayer


func _ready() -> void:
	preload("res://scenes/main.tscn")
	preload("res://scenes/lvl2.tscn")
	preload("res://scenes/lvl3.tscn")
	await get_tree().create_timer(3).timeout
	if Lvls.l1 == false:
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	elif Lvls.l2 == false:
		get_tree().change_scene_to_file("res://scenes/lvl2.tscn")
	elif Lvls.l3 == false:
		get_tree().change_scene_to_file("res://scenes/lvl3.tscn")
