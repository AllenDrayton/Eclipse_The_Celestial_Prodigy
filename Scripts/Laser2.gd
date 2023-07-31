extends RigidBody2D

var direction = Vector2.RIGHT
var fire_attack_speed = Vector2(2000, 0)
var angle = null

func _ready():
	#set_as_toplevel(true)
	apply_impulse(Vector2(), Vector2(fire_attack_speed).rotated(rotation))
	angle = Vector2(fire_attack_speed).rotated(rotation)
	

func _on_Damager_area_entered(area):
	if area.is_in_group("playerHurtbox"):
		queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
