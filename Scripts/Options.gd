extends Control


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ExitFullScreen"):
		OS.set_window_fullscreen(false)



func _on_Back_pressed():
	queue_free()
