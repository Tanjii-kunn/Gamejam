extends Area2D

@export var speed: float = 300.0  # Speed of the bullet
@export var direction: Vector2 = Vector2.RIGHT  # Direction of movement


func _process(delta: float) -> void:
	position += direction * speed * delta  # Move the bullet
	
func _on_body_entered(body):
	if body is enemy:
		body.healthdep()
		self.queue_free()
	elif body is benemy:
		body.healthdep()
		self.queue_free()
	
