class_name enemy
extends CharacterBody2D

var dir = 0
@onready var anim = $AnimatedSprite2D
var speed = 60
@onready var timer: Timer = $Timer
var detected: bool = false
var can_shoot: bool = true
@onready var bullet_scene = preload("uid://1vl4u67tl7qd") 
@export var shoot_cooldown: float = 1.3

# 添加推力相关变量
var mass = 1.0  # 敌人质量
var push_resistance = 0.7  # 推力抵抗系数
var is_being_pushed = false
var push_velocity = Vector2.ZERO
var push_deceleration = 5.0  # 推力减速率

# 获取敌人质量的方法
func get_custom_mass():
	return mass

# 应用推力的方法
func apply_push(force):
	is_being_pushed = true
	push_velocity = force * (1.0 - push_resistance)
	
	# 创建一个计时器来恢复正常状态
	await get_tree().create_timer(1.0).timeout
	is_being_pushed = false

# 添加受伤方法
func take_damage(damage_amount):
	# 这里可以添加生命值系统
	# 如果敌人有生命值，可以在这里减少
	# 如果没有，可以直接销毁敌人
	queue_free()

func _physics_process(delta: float) -> void:
	# 如果正在被推动，应用推力
	if is_being_pushed:
		# 应用推力并逐渐减小
		velocity = push_velocity
		push_velocity = push_velocity.move_toward(Vector2.ZERO, push_deceleration * delta)
		move_and_slide()
		return
		
	# 原有的敌人行为逻辑
	if detected == false:
		move()
		handleani()
		timer.wait_time = randf_range(3 , 7)
	else:
		shoot()

	if $AnimatedSprite2D.flip_h == false:
		$Area2D.rotation = 0
	else:
		$Area2D.rotation = -180
	$dire.wait_time = randf_range(4 , 9)

func handleani():
	if  dir == 0:
		anim.play("idle")
	else:
		anim.play("run")


func _on_timer_timeout() -> void:
	if dir == 0:
		dir = 1
	elif dir == 1:
		dir = 0

func move():
	if not is_on_floor():
		velocity.y += 9.91
	else:
		velocity.y = 0


	if $"d left".is_colliding():
		if dir == 1:
			dir = -1
		elif dir == -1:
			dir = 1

	if $"d right".is_colliding():
		if dir == 1:
			dir = -1
		elif dir == -1:
			dir = 1

	if dir < 0:
		anim.flip_h = true
	else:
		anim.flip_h = false

	if $left.is_colliding():
		if dir == 1:
			dir = -1
		elif dir == -1:
			dir = 1

	if $right.is_colliding():
		if dir == 1:
			dir = -1
		elif dir == -1:
			dir = 1

	velocity.x = dir * speed
	move_and_slide()

func ondetec():
	dir = 0
	anim.play("shoot")
	await get_tree().create_timer(shoot_cooldown).timeout
	return

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is player:
		ondetec()
		detected = true
	if body.position.x - position.x > 0:
		anim.flip_h = false
	else:
		anim.flip_h = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is player:
		detected = false



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


func _on_dire_timeout() -> void:
	if dir == 1:
		dir = -1
	elif dir == -1:
		dir = 1
