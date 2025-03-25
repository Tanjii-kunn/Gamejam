class_name windbull
extends Area2D

@export var speed: float = 300.0  # Speed of the bullet
@onready var direction = Vector2.ZERO

func _ready() -> void:
	$AudioStreamPlayer2D.play()

func _process(delta: float) -> void:
	position += direction * speed * delta
	if direction.x < 0:
		$Sprite2D.flip_h = true
	else:
		$Sprite2D.flip_h = false




func _on_timer_timeout() -> void:
	queue_free()
