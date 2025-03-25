extends CharacterBody2D

var speed = 54
var dir = 1
@onready var l: RayCast2D = $l
@onready var r: RayCast2D = $r
@onready var dl: RayCast2D = $dl
@onready var dr: RayCast2D = $dr
@onready var up_1: RayCast2D = $up1
@onready var up_2: RayCast2D = $up2
@onready var an: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	$Timer.autostart = true
	$Timer.wait_time = randf_range(0.6 , 1.4)
	velocity.x = dir * speed 
	move_and_slide()
	
	velocity.y += 9.81
	
	if not dir == 0:
		an.play("walk")
	
	if dir == 1:
		an.flip_h = false
	elif dir == -1:
		an.flip_h = true
	
	if l.is_colliding():
		dir = 1
	elif r.is_colliding():
		dir = -1
		
	if not dl.is_colliding():
		dir = 1
	elif not dr.is_colliding():
		dir = -1
		
	if up_1.is_colliding() or up_2.is_colliding():
		$Area2D/CollisionShape2D.disabled = true
		dir = 0
		an.play("death")
		await an.animation_finished
		queue_free()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is player:
		body.cchealth -= randf_range(1 , 3)


func _on_timer_timeout() -> void:
	dir = 1 or -1
