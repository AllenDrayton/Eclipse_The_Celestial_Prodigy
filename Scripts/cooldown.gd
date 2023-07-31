extends Node

var time = 0.0
var max_time = 0.0

func _init(max_time):
	self.max_time = max_time
	self.time = 0
	
func tick(delta):
	time = max(time - delta, 0)
	
func is_ready():
	#if timer is still ticking return false
	if time > 0:
		return false
	# reset timer and return true
	time = max_time
	return true
