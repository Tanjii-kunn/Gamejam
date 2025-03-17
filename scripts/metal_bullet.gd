extends Area2D

class_name metal_bullet

@export var speed: float = 300.0  # Bullet speed
@export var direction: Vector2 = Vector2.RIGHT  # Movement direction
@export var damage: float = 2.0  # Damage value

func _ready():
	# Rotate bullet based on direction
	rotation = direction.angle()
	
	# Ensure all child nodes (including Sprite2D) rotate with the bullet
	for child in get_children():
		if child is Sprite2D:
			# If the bullet texture is not originally facing right, additional rotation may be needed
			# Default assumes bullet texture is facing right, if not, uncomment the line below and adjust the angle
			# child.rotation = 0  # Adjust this angle value if needed
			pass

func _physics_process(delta: float) -> void:
	# Use _physics_process instead of _process for smoother movement
	position += direction * speed * delta  # Move bullet
	
func _on_body_entered(body):
	if body is enemy:
		body.take_damage(damage)
		queue_free()
	elif body.is_in_group("destructible"):
		body.destroy()
		queue_free()
	elif body.is_in_group("solid"):
		queue_free() 
