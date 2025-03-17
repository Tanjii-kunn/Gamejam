extends StaticBody2D

class_name destructible_object

@export var health: float = 1.0  # Object health

func _ready():
    # Add object to "destructible" group
    add_to_group("destructible")

func destroy():
    health -= 1.0
    if health <= 0:
        # Can add destruction animation or particle effects here
        queue_free() 