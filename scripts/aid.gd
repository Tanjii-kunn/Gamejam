extends Area2D




func _on_body_entered(body: Node2D) -> void:
	if body is player:
		if body.cchealth < 10:
			body.regen()
			queue_free()
