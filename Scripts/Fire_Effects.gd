extends Area2D

onready var sprite_animation = $AnimatedSprite
onready var animation_player = $AnimationPlayer
var remove_delay_time = 3

onready var audioPlayer = $AudioStreamPlayer2D

func _ready():
	AOEAttack()
	audioPlayer.play()
	
	
func AOEAttack():
	sprite_animation.play("firering")
	animation_player.play("Lava")
	#yield(get_tree().create_timer(remove_delay_time), "timeout")
	$FireEffectTimer.start()
	
	


func _on_FireEffectTimer_timeout():
	self.queue_free()
