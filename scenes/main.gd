extends Node2D

func _ready() -> void:
	$player/player.position = Playerpos.playerposx
	if Bgmusic.playing == false:
		Bgmusic.play()
