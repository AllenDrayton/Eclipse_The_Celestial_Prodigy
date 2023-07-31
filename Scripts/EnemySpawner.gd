extends Node2D


onready var animation = $AnimatedSprite
onready var timer = $Timer
onready var audioPlayer = $AudioStreamPlayer2D

func _ready():
	set_as_toplevel(true)
	audioPlayer.play()
	playAnimation()

func playAnimation():
	animation.play("Spawning")
	timer.start()




func _on_Timer_timeout():
	queue_free()
