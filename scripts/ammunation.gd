extends Area2D



func _on_body_entered(body: Node2D) -> void:
	if body is player:
		if body.ammo < 10:
			body.max_ammo = 20
			body.ammo = 10
			self.queue_free()
		elif body.max_ammo < 20:
			body.max_ammo = 20
			body.ammo = 10
			self.queue_free()
