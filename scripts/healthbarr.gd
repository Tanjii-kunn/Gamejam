extends TextureProgressBar

@onready var timer: Timer = $Timer

func _physics_process(delta: float) -> void:
	if value == 10:
		print("jee")



	if Input.is_action_just_pressed("mouse"):
		value -= 1


func _on_timer_timeout() -> void:
	print("nigga")
	
