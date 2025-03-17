extends Area2D



func _on_body_entered(body: Node2D) -> void:
	if body is player:
		body.max_ammo = 20
		body.ammo = 10
		self.queue_free()
