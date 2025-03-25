extends Area2D




func _on_body_entered(body: Node2D) -> void:
	if body is player:
		if body.cchealth < 10:
			body.regen()
			$AudioStreamPlayer2D.play()
			$Sprite2D.visible = false
			$CollisionShape2D.disabled = true
			await get_tree().create_timer(0.3).timeout
			queue_free()
			
