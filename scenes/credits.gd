extends Control

func _ready() -> void:
	
	if Bgmusic.playing == true:
		Bgmusic.stop()
		$AudioStreamPlayer2D.play()
	
	$AnimatedSprite2D.visible = true
	$AnimatedSprite2D.play("default")
	await $AnimatedSprite2D.animation_finished
	$AnimatedSprite2D.visible = false
	$AnimationPlayer.play("new_animation")
	await $AnimationPlayer.animation_finished
	get_tree().quit()
