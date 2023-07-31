extends Area2D

onready var animatedSprite = $AnimatedSprite
onready var collision = $CollisionShape2D
onready var collision_timer = $collisionTimer
onready var audioPlayer = $AudioStreamPlayer2D

func _ready():
	set_as_toplevel(true)
	Play_animation()
	audioPlayer.play()
	Signals.connect("activate_nova", self, "open_collision")

func Play_animation():
	animatedSprite.play("Gass")


func open_collision():
	collision.set_deferred("disabled", false)
	collision_timer.start()



func _on_collisionTimer_timeout():
	queue_free()
