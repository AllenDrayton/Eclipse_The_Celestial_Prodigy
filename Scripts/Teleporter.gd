extends Area2D

onready var animation = $AnimatedSprite

onready var audioPlayer = $AudioStreamPlayer2D

func _on_Teleporter_body_entered(body):
	if body.is_in_group("Player"):
		animation.play("teleporting")
		audioPlayer.play()
		$Animation_timer.start()
		
		

func _on_Animation_timer_timeout():
	get_tree().change_scene("res://Scn/Grass_Land_Map.tscn")


func _on_Teleporter_body_exited(body):
	if body.is_in_group("Player"):
		animation.stop()
		audioPlayer.stop()
		animation.frame = 0
		$Animation_timer.stop()
