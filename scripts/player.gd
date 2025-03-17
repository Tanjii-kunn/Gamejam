class_name player
extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@export var shoot_cooldown: float = 0.15  # Reduced cooldown time from 0.3s to 0.15s to increase firing speed
var can_shoot: bool = true
const SPEED = 100
const JUMP_VELOCITY = -210.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_shooting = false
@export var move: bool = false
@onready var bullet_scene = preload("uid://b10v1out16h0v")  # Load bullet scene
var cchealth = 10
@export var max_health = 10
var dmg = randf_range(1 , 3)
var regenhealth: float = randf_range(1, 3)
@onready var metal_bullet_scene = preload("res://scenes/MetalBullet.tscn")
@onready var wind_bullet_scene = preload("res://scenes/WindBullet.tscn")
var jetpack_force = -100.0  # Upward force when shooting wind bullets downward
var jetpack_duration = 0.2  # Hovering duration
var is_jetpacking = false  # Whether player is currently using wind bullet hovering

# Bullet type variables
enum BulletType {METAL, WIND}
var mouse_position = Vector2.ZERO  # Store mouse position

# Crosshair related
@onready var crosshair_scene = preload("res://scenes/Crosshair.tscn")  # Preload crosshair scene
var crosshair = null  # Crosshair instance

# Recoil related variables
@export var recoil_coefficient: float = 200.0  # Recoil force coefficient
var recoil_active = false  # Whether recoil is active
var recoil_timer = 0.0  # Recoil timer
var recoil_duration = 0.2  # Recoil duration
var recoil_decay = 0.9  # Recoil decay factor

# Jump and wind bullet limitation
var has_shot_wind_in_air = false  # Track if player has shot a wind bullet during current jump
var was_on_floor = true  # Track if player was on floor in previous frame

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # Default is "Esc" key
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)  # Unlock mouse
	# Remove or comment out the line below to prevent mouse capture
	# elif event.is_action_pressed("mouse"):
	# 	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # Lock mouse
	
	# Update mouse position
	if event is InputEventMouseMotion:
		mouse_position = event.position


func _ready():
	# Set mouse mode to visible so player can see the cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Create crosshair
	create_crosshair()


# Create crosshair
func create_crosshair():
	# Remove existing crosshair if any
	if crosshair != null:
		crosshair.queue_free()
	
	# Create new crosshair
	crosshair = crosshair_scene.instantiate()
	
	# Add crosshair to scene
	# Use call_deferred to avoid "Parent node is busy" error
	get_tree().root.call_deferred("add_child", crosshair)


func _physics_process(delta: float) -> void:
	if move == true:
		apply_gravity(delta)
		handle_recoil(delta)  # Handle recoil
		handle_jump()
		handle_movement()
		handle_animation()
		update_player_facing()
		
		# Handle shooting input
		if Input.is_action_just_pressed("shoot") and can_shoot:
			# If player is already shooting, reset shooting state
			if is_shooting:
				is_shooting = false
			
			shoot()
			anim.play("shoot")
			is_shooting = true
		
		# Reset wind bullet limitation when player lands
		if is_on_floor() and not was_on_floor:
			has_shot_wind_in_air = false
		
		# Update floor state for next frame
		was_on_floor = is_on_floor()

	$CanvasLayer/regent.wait_time = randf_range(0.4 , 0.9)

	# Update UI display with current bullet type
	var current_bullet_type = BulletType.METAL if is_on_floor() else BulletType.WIND
	var bullet_type_text = "Metal" if current_bullet_type == BulletType.METAL else "Wind"
	
	# Add indicator if wind bullet has been used in air
	if not is_on_floor() and has_shot_wind_in_air:
		bullet_type_text += " (Used)"
	
	$CanvasLayer/no.text = bullet_type_text + " Bullet"

	if cchealth <= 0:
		get_tree().reload_current_scene()
		
	if cchealth < 10:
		$CanvasLayer/regent.start()

# Handle recoil
func handle_recoil(delta):
	if recoil_active:
		recoil_timer += delta
		
		# Apply recoil decay
		velocity *= recoil_decay
		
		# Reset state when recoil time ends
		if recoil_timer >= recoil_duration:
			recoil_active = false
			recoil_timer = 0.0

# Update player facing direction based on mouse position
func update_player_facing():
	var mouse_pos = get_global_mouse_position()
	anim.flip_h = mouse_pos.x < global_position.x

func apply_gravity(delta: float):
	if not is_on_floor() and not is_jetpacking:
		velocity.y += gravity * delta
func handle_jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		has_shot_wind_in_air = false  # Reset wind bullet usage when jumping
func handle_movement():
	# If recoil is active, don't process normal movement
	if recoil_active:
		move_and_slide()
		return
		
	var direction := Input.get_axis("left", "right")

	if direction:
		velocity.x = direction * SPEED
		# Don't set flip_h here, it's handled in update_player_facing
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
func handle_animation():
	# Only handle movement animations, shooting is handled separately
	if is_shooting:
		return

	if velocity.x != 0:
		anim.play("run")
	else:
		anim.play("idle")

func shoot():
	if not can_shoot:
		return  # Prevent shooting during cooldown
	
	# Determine bullet type based on whether player is on floor
	var current_bullet_type = BulletType.METAL if is_on_floor() else BulletType.WIND
	
	# Check if player has already shot a wind bullet in this jump
	if current_bullet_type == BulletType.WIND and has_shot_wind_in_air and not is_on_floor():
		# Cannot shoot wind bullet again in this jump
		return
	
	can_shoot = false  # Disable shooting
	
	var bullet_type = metal_bullet_scene if current_bullet_type == BulletType.METAL else wind_bullet_scene
	var shoot_direction = Vector2.ZERO
	
	# Get mouse position
	var mouse_pos = get_global_mouse_position()
	
	# If using wind bullet and pressing down, shoot downward
	if current_bullet_type == BulletType.WIND and Input.is_action_pressed("down"):
		shoot_direction = Vector2.DOWN
		apply_jetpack_force()
	else:
		# Calculate direction vector from player to mouse
		shoot_direction = (mouse_pos - global_position).normalized()
	
	var bullet = bullet_type.instantiate()
	get_parent().add_child(bullet)
	
	# Position bullet based on shooting direction
	if shoot_direction.is_equal_approx(Vector2.DOWN):
		bullet.position = global_position + Vector2(0, 10)
	else:
		# Offset bullet position to avoid collision with player
		bullet.position = global_position + shoot_direction * 20
	
	# Set bullet direction
	bullet.direction = shoot_direction
	
	# Apply recoil if using wind bullet
	if current_bullet_type == BulletType.WIND:
		var recoil_force = -shoot_direction * recoil_coefficient  # Use exported variable
		velocity += recoil_force
		recoil_active = true  # Activate recoil state
		recoil_timer = 0.0  # Reset recoil timer
		
		# Mark that player has shot a wind bullet in this jump
		if not is_on_floor():
			has_shot_wind_in_air = true
	
	# Start cooldown timer
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true  # Allow shooting again

func apply_jetpack_force():
	is_jetpacking = true
	velocity.y = jetpack_force
	
	# Create timer to limit hovering time
	await get_tree().create_timer(jetpack_duration).timeout
	is_jetpacking = false

func _on_regent_timeout() -> void:
	cchealth += regenhealth
