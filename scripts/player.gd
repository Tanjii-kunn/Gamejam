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
var reload: bool = true
var ammo: float
@export var max_ammo: float = 20

var cchealth = 10
@export var max_health = 10
var dmg = randf_range(1 , 3)
var regenhealth: float = randf_range(1, 3)
@onready var winfbull = preload("uid://coeffjy8p8twp")

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

	$CanvasLayer/regent.wait_time = randf_range(0.4 , 0.9)

	$CanvasLayer/no.text = str(ammo) +"/"+ str(max_ammo)
	


	if cchealth <= 0:
		get_tree().reload_current_scene()
		

	if cchealth < 10:
		$CanvasLayer/regent.start()


	if ammo == 0:
		reload = false
	else:
		reload = true

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
		if reload:
			is_shooting = true
			anim.play("shoot")
			shoot()
			await anim.animation_finished
			is_shooting = false
			return
		else:
			is_shooting = true
			anim.play("reload")
			await anim.animation_finished
			reload = true
			ammo = 10
			if not max_ammo == 0:
				max_ammo -= ammo
			is_shooting = false
			return 

	if not is_shooting:
		if velocity.x != 0:
			anim.play("run")
		else:
			anim.play("idle")


func shoot():
	if not can_shoot:
		return  # Prevent shooting if cooldown is active
	can_shoot = false  # Disable shooting
	if ammo > 0:
		ammo -= 1
		
	var bullet = bullet_scene.instantiate()
	var windbullet = winfbull.instantiate()
	if is_on_floor():
		get_parent().add_child(bullet)
	else:
		get_parent().add_child(windbullet)
	

	# Position bullet in front of the player
	if is_on_floor():
		bullet.position = global_position + Vector2(4 if not anim.flip_h else -4, -4)
	# Set bullet direction
		bullet.direction = Vector2.LEFT if anim.flip_h else Vector2.RIGHT
	else:
		windbullet.position = global_position + Vector2(4 if not anim.flip_h else -4, -4)
	# Set bullet direction
		windbullet.direction = Vector2.LEFT if anim.flip_h else Vector2.RIGHT


	# Start cooldown timer
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true  # Allow shooting again


func _on_regent_timeout() -> void:
	cchealth += regenhealth
