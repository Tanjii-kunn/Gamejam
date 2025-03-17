extends Area2D

class_name trigger

signal triggered

@export var one_time_use: bool = true
var has_been_triggered: bool = false

func _ready():
    # Add object to "trigger" group
    add_to_group("trigger")

func activate():
    if one_time_use and has_been_triggered:
        return
        
    has_been_triggered = true
    emit_signal("triggered")
    
    # Can add trigger animation or effects here 