extends RigidBody2D

onready var line = $Line2D
onready var end = $end
onready var damager = $Damager/CollisionShape2D

onready var audioPlayer = $AudioStreamPlayer2D

var fire_attack_speed = Vector2(800, 0)
var direction = Vector2.RIGHT
var target = null
var angle = null

func _physics_process(delta):
	if target:
		direction = target.global_position 
		direction = direction.normalized()
		look_at(target.global_position)

func _ready():
	#set_as_toplevel(true)
	
	audioPlayer.play()
	
	apply_impulse(Vector2(), Vector2(fire_attack_speed).rotated(rotation))
	
	angle = Vector2(fire_attack_speed).rotated(rotation)
	

func _on_Aiming_area_body_entered(body):
	if body.is_in_group("Player"):
		target = body


func _on_Damager_area_entered(area):
	if area.is_in_group("playerHurtbox"):
		queue_free()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
