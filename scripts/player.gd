extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var SPEED = 210.0
var JUMP_VELOCITY = -250.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("left", "right")

	if Input.is_action_pressed("crouch"):
		anim.play("crouch")
		SPEED = 180

	if direction < 0:
		anim.flip_h = true
	else:
		anim.flip_h = false

	if direction:
		anim.play("run")
	else:
		anim.play("idle")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
