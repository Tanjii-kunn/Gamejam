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
@onready var bullet_scene = preload("uid://b10v1out16h0v") 
var reload: bool = true
var ammo: float
@export var max_ammo: float = 20
var ccjump: float
var maxjump: float = 10
var cchealth = 10
@export var max_health = 10
var dmg = randf_range(1 , 3)
var regenhealth: float
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
		anim.flip_h = mousepos.x < 0

	if move == false:
		anim.play("idle")
		anim.flip_h = false

	if is_on_floor():
		ccjump = 0

	$CanvasLayer/health/regent.wait_time = randf_range(0.4 , 0.9)
	$CanvasLayer/no.text = str(ammo) +"/"+ str(max_ammo)
	regenhealth = max_health - cchealth

	if Input.is_action_just_pressed("reload") and ammo < 10 and max_ammo > 0:
		_reload_weapon()

	if cchealth <= 0:
		if $end.is_stopped():
			$end.start()

	if cchealth < 10:
		$CanvasLayer/health/regent.start()

	reload = ammo > 0

func apply_gravity(delta: float):
	if not is_on_floor():
		velocity.y += gravity * delta

func handle_jump():
	if Input.is_action_just_pressed("jump") and ccjump < 1:
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
		else:
			_reload_weapon()
		return

	elif Input.is_action_just_pressed("mouse") and can_push and ammo > 4:
		is_shooting = true
		anim.play("shoot")
		pushshoot()
		await anim.animation_finished
		is_shooting = false
		return

	if not is_shooting:
		anim.play("run" if velocity.x != 0 else "idle")

func _reload_weapon():
	$reload.play()
	anim.play("reload")
	is_shooting = true
	await anim.animation_finished
	if max_ammo > 0:
		reloded_ammo = min(10 - ammo, max_ammo)
		ammo += reloded_ammo
		max_ammo -= reloded_ammo
	reload = ammo > 1
	is_shooting = false

func shoot():
	if not can_shoot or ammo <= 0:
		return 
	can_shoot = false
	ammo -= 1

	if not $left.is_colliding() and not $right.is_colliding():
		position.x += 10 if anim.flip_h else -10

	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.position = global_position + Vector2(4 if not anim.flip_h else -4, -4)
	bullet.direction = Vector2.LEFT if anim.flip_h else Vector2.RIGHT

	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true

func pushshoot():
	if not can_push or ammo <= 4:
		return
	ammo -= 4

	can_push = false
	var windbullet = winfbull.instantiate()
	get_parent().add_child(windbullet)
	windbullet.position = global_position + Vector2(4 if not anim.flip_h else -4, -4)
	windbullet.direction = Vector2.LEFT if anim.flip_h else Vector2.RIGHT

	await get_tree().create_timer(shoot_cooldown).timeout
	can_push = true

func regen():
	cchealth += regenhealth

func _on_end_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/death.tscn")
