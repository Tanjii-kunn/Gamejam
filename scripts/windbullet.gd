class_name windbull
extends Area2D

@export var speed: float = 300.0  # Speed of the bullet
@onready var direction = Vector2.ZERO
@onready var Player: player = $player/player


func _process(delta: float) -> void:
	position += direction * speed * delta
	if direction.x < 0:
		$Sprite2D.flip_h = true
	else:
		$Sprite2D.flip_h = false


func _on_body_entered(body):
	if body is enemy:
		self.queue_free()
