extends Area2D

var radius 
var expansion_time
var damage_targets = []

onready var collision = $CollisionShape2D
onready var animation = $AnimationPlayer
onready var smoke_animation = $Smoke
onready var starfall_animation = $Starfall
onready var audioPlayer = $AudioStreamPlayer2D

var circle_shape = preload("res://Resourses/CircleShape.res")

func _ready():
	set_as_toplevel(true)
	radius = 375
	expansion_time = 0.45
	audioPlayer.play()
	SuperNova_Shockwave()
	

func SuperNova_Shockwave():
	starfall_animation.play("starfall")
	smoke_animation.play("Smoke")
	animation.play("SuperNova")
	var radius_step = radius / (expansion_time / 0.05)
	while collision.get_shape().radius <= radius:
		var shape = circle_shape.duplicate()
		shape.set_radius(collision.get_shape().radius + radius_step)
		collision.set_shape(shape)
		var targets = get_overlapping_bodies()
		for target in targets:
			if target.is_in_group("Reptiles") || target.is_in_group("HellBeast"):
				if damage_targets.has(target):
					continue
				else:
					target.SwordHit()
					damage_targets.append(target)
		yield(get_tree().create_timer(0.05), "timeout")
		continue
	queue_free()
