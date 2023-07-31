extends Camera2D

#func _ready():
#	pass

## I can adjust these variables to control camera movement speed and smoothing
#const CAMERA_MOVE_SPEED = 500
#const CAMERA_SMOOTHNESS = 10
#
## Set this to the player character node
#onready var player = get_parent()
#
## Set this to the current position of the mouse cursor
#var cursor_position = Vector2.ZERO
#
#func _process(delta):
#	# Call the get_camera_mouse_position() function to get the position of the mouse cursor relative to the camera
#	cursor_position = get_viewport().get_mouse_position()
#
#	# Calculate the desired camera position based on the player and cursor positions
#	var desired_position = player.global_position + (cursor_position - get_viewport_rect().size / 2)
#
#	# Smoothly interpolate the camera position towards the desired position
#	position = position.linear_interpolate(desired_position, CAMERA_MOVE_SPEED * delta / CAMERA_SMOOTHNESS)
#
#	# Adjust the zoom level of the camera to keep the player and environment in view
#	var viewport_size = get_viewport_rect().size
#	var zoom_factor = min(viewport_size.x / 640, viewport_size.y / 360)
#	zoom = Vector2(zoom_factor, zoom_factor)



## This function returns the position of the mouse cursor relative to the camera
#func get_camera_mouse_position(camera):
#	var global_mouse_pos = get_global_mouse_position()
#	var camera_global_pos = camera.get_global_position()
#	return global_mouse_pos - camera_global_pos

