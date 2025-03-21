class_name player
extends CharacterBody2D


@onready var jumpscare: AnimatedSprite2D = $jumpscare
@export_category("Player Movement")
@export var move: bool = false
@export var can_push:bool = false
@export var ddjump: bool = false
@export_category("Other Shit")
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@export var shoot_cooldown: float = 0.3  # 0.3 seconds cooldown
var can_shoot: bool = true
const SPEED = 120
var JUMP_VELOCITY = -270
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_shooting = false
@onready var bullet_scene = preload("uid://b10v1out16h0v")  # Load bullet scene
var reload: bool = true
var ammo: float
@export var max_ammo: float = 20
var ccjump: float
var maxjump: float
var cchealth = 10
@export var max_health = 10
var dmg = randf_range(1 , 3)
var regenhealth: float = randf_range(1, 3)
@onready var winfbull = preload("res://scenes/windbullet.tscn")
var reloded_ammo: float
var blastdmg: float = randf_range(4, 7)




func _ready():
	ammo = 10
	$CanvasLayer.visible = true

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	if move == true:
		handle_jump()
		handle_movement()
		handle_animation()
		var mousepos = get_local_mouse_position()
		if mousepos.x < 0:
			anim.flip_h = true
		else:
			anim.flip_h = false


	if move == false:
		anim.play("idle")
		anim.flip_h = false

	if is_on_floor():
		ccjump = 0

	$CanvasLayer/health/regent.wait_time = randf_range(0.4 , 0.9)

	$CanvasLayer/no.text = str(ammo) +"/"+ str(max_ammo)



	if ammo < 10:
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

	if ammo <= 1 :
		reload = false
	else:
		reload = true

func apply_gravity(delta: float):
	if not is_on_floor():
		velocity.y += gravity * delta


func handle_jump():
	if Input.is_action_just_pressed("jump"):
		if ccjump < 1:
			velocity.y = JUMP_VELOCITY
			ccjump += 1


	if is_on_floor():
		ccjump = 0

func handle_movement():
	var direction := Input.get_axis("left", "right")



	if direction:
		velocity.x = direction * SPEED
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
		if can_push == true:
			if ammo > 4:
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
		return 
	can_shoot = false  # Disable shooting

	if ammo > 0:
		ammo -= 1
	
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
	if can_push == false:
		return
	
	if ammo > 4:
		ammo -= 4
		
	
	can_push = false
	var windbullet = winfbull.instantiate()
	get_parent().add_child(windbullet)
	windbullet.position = global_position + Vector2(4 if not anim.flip_h else -4, -4)
	windbullet.direction = Vector2.LEFT if anim.flip_h else Vector2.RIGHT

	# Cooldown before next shot
	await get_tree().create_timer(shoot_cooldown).timeout
	can_push = true  # Allow shooting again

func _on_regent_timeout() -> void:
	cchealth += regenhealth

func _on_end_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/death.tscn")
