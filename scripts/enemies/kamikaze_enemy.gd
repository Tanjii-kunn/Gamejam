extends CharacterBody2D

class_name kamikaze_enemy

# Behavior states
enum State {IDLE, CHASE, EXPLODE_COUNTDOWN, EXPLODE}

# Export variables for customization
@export var speed: float = 150.0  # Chase speed
@export var detection_radius: float = 300.0  # Detection radius
@export var explosion_radius: float = 100.0  # Explosion damage radius
@export var explosion_damage: int = 5  # Damage to player
@export var explosion_countdown: float = 3.0  # Time before explosion
@export var chase_acceleration: float = 15.0  # Acceleration when chasing

# Internal variables
var current_state: State = State.IDLE
var countdown_timer: float = explosion_countdown
var player: Node2D = null
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var explosion_particles: CPUParticles2D

# Animation and visual feedback
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var explosion_area: Area2D = $ExplosionArea
@onready var countdown_label: Label = $CountdownLabel
@onready var alert_indicator: Sprite2D = $AlertIndicator

func _ready():
	print("Kamikaze enemy initialized")
	
	# Initialize components
	countdown_label.visible = false
	alert_indicator.visible = false
	
	# Setup explosion particles
	explosion_particles = $ExplosionParticles
	explosion_particles.emitting = false
	
	# Setup collision shapes
	var detection_shape = detection_area.get_node("CollisionShape2D").shape
	if detection_shape is CircleShape2D:
		detection_shape.radius = detection_radius
		print("Detection radius set to: ", detection_radius)
	
	var explosion_shape = explosion_area.get_node("CollisionShape2D").shape
	if explosion_shape is CircleShape2D:
		explosion_shape.radius = explosion_radius
		print("Explosion radius set to: ", explosion_radius)
	
	# Connect signals
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)
	explosion_area.body_entered.connect(_on_explosion_area_body_entered)
	
	# Ensure areas are monitored
	detection_area.monitoring = true
	detection_area.monitorable = true
	explosion_area.monitoring = true
	explosion_area.monitorable = true
	
	print("Kamikaze enemy initialization completed, waiting for player")

func _physics_process(delta):
	# Apply gravity when in air
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Display current state for debugging
	if Engine.is_editor_hint() == false:  # Only show in game runtime
		if countdown_label:
			match current_state:
				State.IDLE:
					countdown_label.text = "IDLE"
					countdown_label.visible = true
				State.CHASE:
					countdown_label.text = "CHASE"
					countdown_label.visible = true
				State.EXPLODE_COUNTDOWN:
					countdown_label.text = str(ceil(countdown_timer))
					countdown_label.visible = true
				State.EXPLODE:
					countdown_label.visible = false
	
	match current_state:
		State.IDLE:
			handle_idle_state()
		State.CHASE:
			handle_chase_state(delta)
		State.EXPLODE_COUNTDOWN:
			handle_explode_countdown_state(delta)
		State.EXPLODE:
			handle_explode_state()
	
	move_and_slide()

func handle_idle_state():
	velocity.x = 0
	
	if animated_sprite and animated_sprite.animation != "idle" and animated_sprite.sprite_frames.has_animation("idle"):
		animated_sprite.play("idle")

func handle_chase_state(delta):
	if animated_sprite and animated_sprite.sprite_frames.has_animation("chase"):
		if animated_sprite.animation != "chase":
			animated_sprite.play("chase")
			alert_indicator.visible = true
			print("Starting chase animation")
	
	if player != null:
		print("Chasing - Current position: ", global_position, " Player position: ", player.global_position)
		
		# Calculate direction vector
		var direction_vector = player.global_position - global_position
		var distance = direction_vector.length()
		var normalized_direction = direction_vector.normalized()
		
		print("Distance: ", distance, " Direction: ", normalized_direction)
		
		# Set facing direction
		if normalized_direction.x < 0:
			animated_sprite.flip_h = true
		else:
			animated_sprite.flip_h = false
		
		# If close enough to player, start countdown
		if distance > explosion_radius * 0.8:
			velocity.x = normalized_direction.x * speed
			print("Movement speed set to: ", velocity)
			
			# If player is above and enemy is on the ground, try to jump
			if normalized_direction.y < -0.5 and is_on_floor():
				velocity.y = -300
				print("Jumping to chase player")
		else:
			# If close enough to player, start countdown
			print("Close enough, starting explosion countdown")
			transition_to_explode_countdown()
	else:
		# Lost target, go back to idle
		print("No player target, returning to idle state")
		velocity.x = 0
		current_state = State.IDLE

func handle_explode_countdown_state(delta):
	if animated_sprite and animated_sprite.sprite_frames.has_animation("countdown"):
		if animated_sprite.animation != "countdown":
			animated_sprite.play("countdown")
	
	# Reduce countdown
	countdown_timer -= delta
	
	# Update countdown display
	countdown_label.text = str(ceil(countdown_timer))
	countdown_label.visible = true
	
	# Continue moving toward player during countdown, but with reduced speed
	if player != null:
		var direction_vector = player.global_position - global_position
		var distance = direction_vector.length()
		var normalized_direction = direction_vector.normalized()
		
		# Set facing direction
		if normalized_direction.x < 0:
			animated_sprite.flip_h = true
		else:
			animated_sprite.flip_h = false
		
		# Move at slower speed (60% of original speed)
		velocity.x = normalized_direction.x * speed * 0.6
		print("Countdown movement speed: ", velocity)
	else:
		velocity.x = 0
	
	# When countdown reaches zero, explode
	if countdown_timer <= 0:
		print("Countdown finished, starting explosion")
		transition_to_explode()

func handle_explode_state():
	# Stop all movement during explosion
	velocity = Vector2.ZERO
	
	# Play explosion animation and particles
	if animated_sprite and animated_sprite.sprite_frames.has_animation("explode"):
		if animated_sprite.animation != "explode":
			animated_sprite.play("explode")
			if explosion_particles:
				explosion_particles.emitting = true
			
			# Deal damage to entities in explosion area
			apply_explosion_damage()
			
			# After explosion effects finish, remove enemy
			print("Explosion complete, will self-destruct")
			await get_tree().create_timer(0.5).timeout
			queue_free()

func transition_to_explode_countdown():
	current_state = State.EXPLODE_COUNTDOWN
	countdown_timer = explosion_countdown
	countdown_label.visible = true
	print("State transition: Starting explosion countdown")

func transition_to_explode():
	current_state = State.EXPLODE
	countdown_label.visible = false
	alert_indicator.visible = false
	print("State transition: Starting explosion")

func apply_explosion_damage():
	print("Applying explosion damage")
	var bodies = explosion_area.get_overlapping_bodies()
	print("Number of bodies in explosion area: ", bodies.size())
	
	for body in bodies:
		print("Checking body: ", body)
		
		# Check if it's an entity that can be damaged (player or enemies)
		if body.has_method("take_damage"):
			print("Entity can take damage: has take_damage method")
			# Calculate damage, can be based on distance
			var distance = global_position.distance_to(body.global_position)
			var damage_multiplier = 1.0 - (distance / explosion_radius)
			var final_damage = int(explosion_damage * damage_multiplier)
			
			if final_damage > 0:
				print("Dealing ", final_damage, " damage to ", body)
				body.take_damage(final_damage)
		# Special handling for cult_memb_1 enemy type
		elif body is enemy:
			print("Detected cult_memb_1 enemy")
			# Damage enemy (if it doesn't have take_damage method, remove from scene)
			body.queue_free()
			print("cult_memb_1 has been destroyed")

func change_state(new_state):
	# Exit current state
	match current_state:
		State.EXPLODE_COUNTDOWN:
			countdown_label.visible = false
	
	# Enter new state
	match new_state:
		State.IDLE:
			animated_sprite.play("idle")
			alert_indicator.visible = false
		State.CHASE:
			animated_sprite.play("chase")
			alert_indicator.visible = true
		State.EXPLODE_COUNTDOWN:
			animated_sprite.play("countdown")
			countdown_timer = explosion_countdown
			countdown_label.visible = true
			alert_indicator.visible = true
		State.EXPLODE:
			explosion_particles.emitting = true
			countdown_label.visible = false
	
	current_state = new_state

func _on_detection_area_body_entered(body):
	print("Body entered detection area: ", body)
	
	if body.is_in_group("player"):
		print("Player detected!")
		player = body
		current_state = State.CHASE
		print("Current state set to: CHASE (", current_state, ")")
	else:
		print("Entity is not a player")

func _on_detection_area_body_exited(body):
	print("Body exited detection area: ", body)
	
	if body.is_in_group("player") and body == player:
		print("Player left detection area")
		# If still chasing, return to idle
		if current_state == State.CHASE:
			current_state = State.IDLE
			alert_indicator.visible = false
			print("Returning to idle state")
		player = null

func _on_explosion_area_body_entered(body):
	print("Body entered explosion area: ", body)
	# In explode countdown state, can consider accelerating countdown
	if current_state == State.EXPLODE_COUNTDOWN and body.is_in_group("player"):
		countdown_timer = min(countdown_timer, 1.0)  # Immediately reduce countdown
		print("Player entered explosion area, accelerating countdown")

# Editor support function
func _get_configuration_warnings():
	var warnings = []
	
	if not has_node("AnimatedSprite2D"):
		warnings.append("This node requires an AnimatedSprite2D child node")
	
	if not has_node("DetectionArea"):
		warnings.append("This node requires an Area2D child named 'DetectionArea'")
	
	if not has_node("ExplosionArea"):
		warnings.append("This node requires an Area2D child named 'ExplosionArea'")
	
	return warnings 
