class_name enemy
extends CharacterBody2D

var dir = 0
var bldmg:float = randf_range(3, 6)
@onready var anim = $AnimatedSprite2D
var speed = 60
@onready var timer: Timer = $Timer
var detected: bool = false
var can_shoot: bool = true
@onready var bullet_scene = preload("uid://1vl4u67tl7qd") 
@export var shoot_cooldown: float = 1.3
@onready var healtn: TextureProgressBar = $healtn
var cchealthh:float = 10
var dmg: float = randf_range(2 ,5)



func _physics_process(_delta: float) -> void:
	if detected == false:
		move()
		handleani()
		timer.wait_time = randf_range(3 , 7)
	else:
		shoot()
		
	push()
	
	healtn.value = cchealthh
	
	if cchealthh < 1:
		queue_free()

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
		dir = 1

	if $right.is_colliding():
		dir = -1

	velocity.x = dir * speed
	move_and_slide()

func healthdep():
	if healtn.value > 0:
		cchealthh -= dmg

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

func push():
	if not $ll.is_colliding() and not $rr.is_colliding():
		if $"1".is_colliding():
			position.x += 20
		elif $"2".is_colliding():
			position.x -= 20
