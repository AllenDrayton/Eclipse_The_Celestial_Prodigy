extends Area2D

onready var animation = $AnimatedSprite

onready var audioPlayer = $AudioStreamPlayer2D


func _on_Teleporter_body_entered(body):
	if body.is_in_group("Player"):
		animation.play("teleporting")
		audioPlayer.play()

func _on_Animation_timer_timeout():
	$Animation_timer.stop()
	queue_free()


func _on_Teleporter_body_exited(body):
	animation.stop()
	audioPlayer.stop()
	animation.frame = 0
	$Animation_timer.start()
	$CollisionShape2D.set_deferred("disabled", true)
