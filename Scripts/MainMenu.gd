extends Control


func _ready():
	#OS.set_window_fullscreen(true)
	#$VBoxContainer/StartButton.grab_focus()
	pass


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ExitFullScreen"):
		OS.set_window_fullscreen(false)



func _on_StartButton_pressed():
	get_tree().change_scene("res://Scn/DungeonMap.tscn")


func _on_OptionButton_pressed():
	var option = load("res://Scn/Options.tscn").instance()
	get_tree().current_scene.add_child(option)


func _on_ExitButton_pressed():
	get_tree().quit()
