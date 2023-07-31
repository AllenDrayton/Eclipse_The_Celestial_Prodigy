extends Node2D

onready var emitter = $Particles2D
onready var timeCreated = Time.get_ticks_msec()

func _ready():
	emitter.emitting = true
	$Timer.start()

#func _process(delta):
#	if Time.get_ticks_msec() - timeCreated > 10000:
#		queue_free()


func _on_Timer_timeout():
	queue_free()
