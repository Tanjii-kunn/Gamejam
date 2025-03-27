class_name benemy
extends CharacterBody2D

var dir = 0
@onready var anim = $AnimatedSprite2D
var speed = 60
@onready var timer: Timer = $Timer
var detected: bool = false
var can_shoot: bool = true
@onready var bullet_scene = preload("uid://1vl4u67tl7qd") 
@export var shoot_cooldown: float = 1.3
var blasting: bool = false
@onready var healtn: TextureProgressBar = $healtn
var cchealthh:float = 10
var dmg: float = randf_range(2 ,5)
var out:bool

func _ready() -> void:
	$blastrd/CollisionShape2D.disabled = true


func _physics_process(_delta: float) -> void:
	if out == false:
		if cchealthh > 0:
			if detected == false:
				move()
				handleani()
				timer.wait_time = randf_range(3 , 7)

		healtn.value = cchealthh
		
		if cchealthh < 1:
			anim.play("die")
			dir = 0
			await anim.animation_finished
			queue_free()

		push()



		if $AnimatedSprite2D.flip_h == false:
			$Area2D.rotation = 0
		else:
			$Area2D.rotation = -180
		$dire.wait_time = randf_range(4 , 9)

func handleani():
	if out == false:
		if blasting == false:
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
	if out == false:
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

func ondetec():
	dir = 0
	blasting = true
	anim.play("blast")
	await anim.animation_finished
	$AudioStreamPlayer2D.play()
	$blastrd/CollisionShape2D.disabled = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is player:
		ondetec()
		detected = true
	if body.position.x - position.x > 0:
		anim.flip_h = false
	else:
		anim.flip_h = true


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


func healthdep():
	if healtn.value > 0:
		cchealthh -= dmg

func _on_blastrd_body_entered(body: Node2D) -> void:
	if body is player:
		body.cchealth -= body.blastdmg
	elif body is enemy:
		body.cchealthh -= body.bldmg
	call_deferred("_disable_collision")

func _disable_collision() -> void:
	$blastrd/CollisionShape2D.disabled = true
	$Area2D/CollisionShape2D.disabled = true
	$AnimatedSprite2D.visible = false
	$CollisionShape2D.disabled = true
	$exp.start()


func _on_exp_timeout() -> void:
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	out = false


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	out = true
