extends Position2D


#onready var parent = get_parent()
##onready var camera = $Camera2D
#
#const MAX_CAMERA_DISTANCE = 80.0
#const MAX_CAMERA_PERCENT = 0.1
#const CAMERA_SPEED = 0.1

#func _ready():
#	pass
	#update_pivot_angle()


#func _physics_process(delta):
#	update_pivot_angle()
#
#
#func update_pivot_angle():
#	rotation = parent.move_direction.angle()


#
#func _process(delta: float) -> void:
#	var viewport = get_viewport()
#	var viewport_center = viewport.size / 2.0
#	var direction = viewport.get_mouse_position() - viewport_center
#	var percent = (direction / viewport.size * 2.0).length()
#	var camera_position: Vector2
#
#	if percent < MAX_CAMERA_PERCENT:
#		camera_position = parent.global_position + direction.normalized() * MAX_CAMERA_DISTANCE * (percent / MAX_CAMERA_PERCENT)
#	else:
#		camera_position = parent.global_position + direction.normalized() * MAX_CAMERA_DISTANCE
#
#	camera.global_position = lerp(camera.global_position, camera_position, CAMERA_SPEED)
