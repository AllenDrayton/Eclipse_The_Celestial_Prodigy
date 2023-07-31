extends Control


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ExitFullScreen"):
		OS.set_window_fullscreen(false)


func _on_MainMenu_pressed():
	get_tree().change_scene("res://Scn/MainMenu.tscn")
