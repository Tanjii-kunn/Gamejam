class_name player
extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@export var shoot_cooldown: float = 0.3  # 0.3 seconds cooldown
var can_shoot: bool = true
const SPEED = 100
const JUMP_VELOCITY = -210.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_shooting = false
@export var move: bool = false
@onready var bullet_scene = preload("uid://b10v1out16h0v")  # Load bullet scene
@onready var texture_progress_bar: TextureProgressBar = $CanvasLayer/TextureProgressBar

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # Default is "Esc" key
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)  # Unlock mouse
	elif event.is_action_pressed("mouse"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # Lock mouse


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float) -> void:
	if move == true:
		apply_gravity(delta)
		handle_jump()
		handle_movement()
		handle_animation()

	if texture_progress_bar.value < 10:
		texture_progress_bar.value += 0.1
		


func apply_gravity(delta: float):
	if not is_on_floor():
		velocity.y += gravity * delta
func handle_jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
func handle_movement():
	var direction := Input.get_axis("left", "right")

	if direction:
		velocity.x = direction * SPEED
		anim.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
func handle_animation():
	if is_shooting:
		return

	if Input.is_action_just_pressed("shoot"):
		is_shooting = true
		anim.play("shoot")
		shoot()
		await anim.animation_finished
		is_shooting = false
		return

	if velocity.x != 0:
		anim.play("run")
	else:
		anim.play("idle")


func shoot():
	if not can_shoot:
		return  # Prevent shooting if cooldown is active

	can_shoot = false  # Disable shooting
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)

	# Position bullet in front of the player
	bullet.position = global_position + Vector2(4 if not anim.flip_h else -4, -4)

	# Set bullet direction
	bullet.direction = Vector2.LEFT if anim.flip_h else Vector2.RIGHT

	# Start cooldown timer
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true  # Allow shooting again
