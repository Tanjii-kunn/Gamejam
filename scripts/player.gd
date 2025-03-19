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
var reloded_ammo: float

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # Default is "Esc" key
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)  # Unlock mouse
	elif event.is_action_pressed("mouse"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  # Lock mouse


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ammo = 10
	
	# 确保玩家被添加到"player"组
	if not is_in_group("player"):
		add_to_group("player")

func _physics_process(delta: float) -> void:
	if move == true:
		apply_gravity(delta)
		handle_jump()
		handle_movement()
		handle_animation()

	$CanvasLayer/health/regent.wait_time = randf_range(0.4 , 0.9)

	$CanvasLayer/no.text = str(ammo) +"/"+ str(max_ammo)
	

	if Input.is_action_just_pressed("reload"):
		anim.play("reload")
		is_shooting = true
		await anim.animation_finished
		if max_ammo > 0:
			if ammo < 10:
				reloded_ammo = 10 - ammo
				ammo += reloded_ammo
				max_ammo = max_ammo - reloded_ammo
		is_shooting = false


	if cchealth <= 0:
		if $end.is_stopped():
			$end.start()

	if cchealth < 10:
		$CanvasLayer/health/regent.start()

	if ammo == 0 :
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
			if max_ammo > 0:
				if ammo < 10:
					reloded_ammo = 10 - ammo
					ammo += reloded_ammo
					max_ammo = max_ammo - reloded_ammo
			reload = true
			is_shooting = false
			return 
	elif Input.is_action_just_pressed("mouse"):
		is_shooting = true
		anim.play("shoot")
		pushshoot()
		await anim.animation_finished
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

	# Regular bullet logic
	if ammo > 0:
		ammo -= 1
	
	if is_on_floor():
		if not $left.is_colliding() and not $right.is_colliding():
			if anim.flip_h:
				position.x += 10
			else:
				position.x -= 10

	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.position = global_position + Vector2(4 if not anim.flip_h else -4, -4)
	bullet.direction = Vector2.LEFT if anim.flip_h else Vector2.RIGHT


	# Cooldown before next shot
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true  # Allow shooting again

func pushshoot():
	var windbullet = winfbull.instantiate()
	get_parent().add_child(windbullet)
	windbullet.position = global_position + Vector2(4 if not anim.flip_h else -4, -4)
	windbullet.direction = Vector2.LEFT if anim.flip_h else Vector2.RIGHT

	# Cooldown before next shot
	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true  # Allow shooting again

func _on_regent_timeout() -> void:
	cchealth += regenhealth

func _on_end_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/death.tscn")

func take_damage(damage_amount: int) -> void:
	# 扣除玩家生命值
	cchealth -= damage_amount
	
	# 如果有受伤动画，可以在这里播放
	# anim.play("hurt")
	
	# 如果有受伤音效，可以在这里播放
	# $HurtSound.play()
	
	# 如果需要无敌时间，可以在这里添加
	# set_deferred("$CollisionShape2D.disabled", true)
	# await get_tree().create_timer(0.5).timeout
	# set_deferred("$CollisionShape2D.disabled", false)
	
	# 检查是否死亡
	if cchealth <= 0:
		if $end.is_stopped():
			$end.start()
