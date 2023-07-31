extends RigidBody2D

onready var animated_sprite =  $AnimatedSprite
var fire_attack_speed = Vector2(2000, 0)
var angle = null
var attack_direction

onready var audioPlayer = $AudioStreamPlayer2D

func _ready():
	#set_as_toplevel(true)
	animated_sprite.play("Burning")
	audioPlayer.play()
	apply_impulse(Vector2(), Vector2(fire_attack_speed).rotated(rotation))
	
	angle = Vector2(fire_attack_speed).rotated(rotation)


func _on_Fire_Attack_Area_area_entered(area):
	$Fire_Attack_lifetime.start()
	if area.is_in_group("playerHurtbox"):
		self.hide()



func _on_Fire_Attack_lifetime_timeout():
	queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
