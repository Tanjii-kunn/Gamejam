extends Area2D

class_name wind_bullet

@export var speed: float = 250.0  # Bullet speed
@export var direction: Vector2 = Vector2.RIGHT  # Movement direction
@export var push_force: float = 500.0  # Base push force
@export var max_lifetime: float = 0.5  # Maximum bullet lifetime

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
	
	# Set maximum bullet lifetime
	await get_tree().create_timer(max_lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	# Use _physics_process instead of _process for smoother movement
	position += direction * speed * delta  # Move bullet
	
func _on_body_entered(body):
	if body is enemy:
		body.apply_push(direction * push_force)
		queue_free()
	elif body.is_in_group("trigger"):
		body.activate()
		queue_free()
	elif body.is_in_group("solid"):
		queue_free()

# Calculate actual push force based on object mass
func calculate_push_force(body):
	var mass = 1.0  # Default mass
	
	if body.has_method("get_custom_mass"):
		mass = body.get_custom_mass()
	elif body is RigidBody2D:
		mass = body.mass
	elif body.is_in_group("light"):
		mass = 0.5
	elif body.is_in_group("heavy"):
		mass = 2.0
	
	# Push force is inversely proportional to mass, but using square root relationship to allow heavy objects to be pushed appropriately
	return push_force / sqrt(mass) 
